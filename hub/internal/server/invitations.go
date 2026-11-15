package server

import (
    "context"
    "encoding/json"
    "errors"
    "time"

    "github.com/google/uuid"
    "github.com/jackc/pgx/v5"

    "git.hakoniwa.ru/tech/himodameshi/hub/internal/api"
    "git.hakoniwa.ru/tech/himodameshi/hub/internal/auth"
    "git.hakoniwa.ru/tech/himodameshi/hub/internal/store"
)

// Срок действия приглашения — из запроса expires_in_days (1–30), по умолчанию 7 суток (HUB-2).
const (
    invitationDefaultDays = 7
    invitationMinDays     = 1
    invitationMaxDays     = 30
)

// ListInvitations отдаёт действующие приглашения команды; список виден только владельцу.
// Истёкшие, отозванные и использованные не показываются (data-model.md, раздел 3.3).
func (s *Server) ListInvitations(ctx context.Context, request api.ListInvitationsRequestObject) (api.ListInvitationsResponseObject, error) {
    userID := sessionFrom(ctx).user.ID
    team, err := s.memberTeam(ctx, s.q, request.TeamId, userID)
    if err != nil {
        return nil, err
    }
    if team.Role != api.TeamRoleOwner {
        return nil, errOwnerOnly
    }

    rows, err := s.q.ListTeamInvitations(ctx, request.TeamId)
    if err != nil {
        return nil, err
    }
    items := make([]api.Invitation, 0, len(rows))
    for _, row := range rows {
        items = append(items, toAPIInvitation(row))
    }
    return api.ListInvitations200JSONResponse{Items: items}, nil
}

// CreateInvitation создаёт одноразовое приглашение. Токен ссылки возвращается один раз —
// на сервере хранится только его SHA-256, как у сеансов (ADR-022). В личное пространство
// приглашать нельзя. Ссылку вида https://<домен>/invite/<token> собирает веб.
func (s *Server) CreateInvitation(ctx context.Context, request api.CreateInvitationRequestObject) (api.CreateInvitationResponseObject, error) {
    days := invitationDefaultDays
    if request.Body != nil && request.Body.ExpiresInDays != nil {
        days = *request.Body.ExpiresInDays
    }
    if days < invitationMinDays || days > invitationMaxDays {
        return nil, validationError(api.FieldError{Field: "expires_in_days", Message: "от 1 до 30 суток"})
    }
    expiresAt := s.now().Add(time.Duration(days) * 24 * time.Hour)

    user := sessionFrom(ctx).user
    var resp api.CreatedInvitation
    err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
        q := s.q.WithTx(tx)

        team, err := lockOwnedTeam(ctx, q, request.TeamId, user.ID)
        if err != nil {
            return err
        }
        if team.IsPersonal {
            return errPersonalTeam
        }

        token, err := auth.NewToken()
        if err != nil {
            return err
        }
        invitationID, err := uuid.NewV7()
        if err != nil {
            return err
        }
        inv, err := q.CreateInvitation(ctx, store.CreateInvitationParams{
            ID:        invitationID,
            TeamID:    team.ID,
            TokenHash: auth.HashToken(token),
            CreatedBy: user.ID,
            ExpiresAt: expiresAt,
        })
        if err != nil {
            return err
        }

        details, err := json.Marshal(map[string]any{
            "id":         inv.ID,
            "expires_at": inv.ExpiresAt.UTC().Format(time.RFC3339),
        })
        if err != nil {
            return err
        }
        if err := q.InsertAuditEvent(ctx, store.InsertAuditEventParams{
            TeamID:  team.ID,
            ActorID: user.ID,
            Event:   "invitation.created",
            Details: details,
        }); err != nil {
            return err
        }

        resp = api.CreatedInvitation{
            Invitation: api.Invitation{
                Id:        inv.ID,
                TeamId:    inv.TeamID,
                CreatedBy: userRef(user),
                CreatedAt: inv.CreatedAt.UTC(),
                ExpiresAt: inv.ExpiresAt.UTC(),
            },
            Token: token,
        }
        return nil
    })
    if err != nil {
        return nil, err
    }
    return api.CreateInvitation201JSONResponse(resp), nil
}

// RevokeInvitation отзывает приглашение; доступно только владельцу команды приглашения.
// Чужому пользователю существование приглашения не раскрывается (not_found). Повторный
// отзыв уже отозванного приглашения отвечает 204 без новой записи в журнале.
func (s *Server) RevokeInvitation(ctx context.Context, request api.RevokeInvitationRequestObject) (api.RevokeInvitationResponseObject, error) {
    userID := sessionFrom(ctx).user.ID
    err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
        q := s.q.WithTx(tx)

        row, err := q.GetInvitationByID(ctx, request.InvitationId)
        if errors.Is(err, pgx.ErrNoRows) {
            return errNotFound
        }
        if err != nil {
            return err
        }
        if row.TeamDeletedAt != nil {
            return errNotFound
        }

        // Только владелец команды приглашения; не-участнику существование не показываем.
        role, err := q.GetMemberRole(ctx, store.GetMemberRoleParams{TeamID: row.TeamID, UserID: userID})
        if errors.Is(err, pgx.ErrNoRows) {
            return errNotFound
        }
        if err != nil {
            return err
        }
        if role != roleOwner {
            return errOwnerOnly
        }

        // RowsAffected показывает, было ли изменение: для уже отозванного приглашения оно нулевое.
        changed, err := q.RevokeInvitation(ctx, request.InvitationId)
        if err != nil {
            return err
        }
        if changed > 0 {
            details, err := json.Marshal(map[string]any{"id": request.InvitationId})
            if err != nil {
                return err
            }
            if err := q.InsertAuditEvent(ctx, store.InsertAuditEventParams{
                TeamID:  row.TeamID,
                ActorID: userID,
                Event:   "invitation.revoked",
                Details: details,
            }); err != nil {
                return err
            }
        }
        return nil
    })
    if err != nil {
        return nil, err
    }
    return api.RevokeInvitation204Response{}, nil
}

// GetInvitationByToken показывает, куда ведёт ссылка, без входа — чтобы посетитель увидел
// название команды до регистрации или входа. Действует только на действующее приглашение.
func (s *Server) GetInvitationByToken(ctx context.Context, request api.GetInvitationByTokenRequestObject) (api.GetInvitationByTokenResponseObject, error) {
    row, err := s.q.GetInvitationPreview(ctx, auth.HashToken(request.Token))
    if errors.Is(err, pgx.ErrNoRows) {
        return nil, errInvitationInvalid
    }
    if err != nil {
        return nil, err
    }
    return api.GetInvitationByToken200JSONResponse{
        TeamName:  row.TeamName,
        ExpiresAt: row.ExpiresAt.UTC(),
    }, nil
}

// AcceptInvitation вступает в команду по одноразовой ссылке. В одной транзакции под
// блокировкой приглашения проверяется его пригодность, лимит участников и отсутствие
// членства, затем добавляется участник и помечается использование. Приглашение одноразовое:
// второй запрос по тому же токену видит used_by и отклоняется.
func (s *Server) AcceptInvitation(ctx context.Context, request api.AcceptInvitationRequestObject) (api.AcceptInvitationResponseObject, error) {
    userID := sessionFrom(ctx).user.ID
    tokenHash := auth.HashToken(request.Token)

    var result api.Team
    err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
        q := s.q.WithTx(tx)

        inv, err := q.LockInvitationByToken(ctx, tokenHash)
        if errors.Is(err, pgx.ErrNoRows) {
            return errInvitationInvalid
        }
        if err != nil {
            return err
        }
        // Пригодность проверяется под блокировкой, чтобы двое не вступили по одной ссылке.
        now := s.now()
        if inv.RevokedAt != nil || inv.UsedBy != nil || !inv.ExpiresAt.After(now) {
            return errInvitationInvalid
        }

        // Блокируем команду: состав и лимит согласованы с другими изменениями состава.
        team, err := q.LockTeam(ctx, inv.TeamID)
        if errors.Is(err, pgx.ErrNoRows) {
            return errInvitationInvalid
        }
        if err != nil {
            return err
        }
        if team.DeletedAt != nil {
            return errInvitationInvalid
        }

        // Уже участник — вступать не нужно.
        if _, err := q.GetMemberRole(ctx, store.GetMemberRoleParams{TeamID: team.ID, UserID: userID}); err == nil {
            return errAlreadyMember
        } else if !errors.Is(err, pgx.ErrNoRows) {
            return err
        }

        count, err := q.CountTeamMembers(ctx, team.ID)
        if err != nil {
            return err
        }
        if max := s.teamPlan(ctx, team).MaxMembers; int(count) >= max {
            return errMemberLimitReached
        }

        if err := q.AddTeamMember(ctx, store.AddTeamMemberParams{TeamID: team.ID, UserID: userID}); err != nil {
            return err
        }
        if err := q.UseInvitation(ctx, store.UseInvitationParams{ID: inv.ID, UsedBy: &userID}); err != nil {
            return err
        }
        details, err := json.Marshal(map[string]any{"invitation_id": inv.ID})
        if err != nil {
            return err
        }
        // Кто вступил — и автор, и субъект события (data-model.md, раздел 3.6).
        if err := q.InsertAuditEvent(ctx, store.InsertAuditEventParams{
            TeamID:        team.ID,
            ActorID:       userID,
            Event:         "member.joined",
            SubjectUserID: &userID,
            Details:       details,
        }); err != nil {
            return err
        }

        result, err = s.memberTeam(ctx, q, team.ID, userID)
        return err
    })
    if err != nil {
        return nil, err
    }
    return api.AcceptInvitation200JSONResponse(result), nil
}

// toAPIInvitation собирает ответное приглашение; ник создателя скрыт, если учётка обезличена.
func toAPIInvitation(row store.ListTeamInvitationsRow) api.Invitation {
    createdBy := api.UserRef{Id: row.CreatedBy}
    if row.CreatedByDeletedAt == nil {
        nickname := row.CreatedByNickname
        createdBy.Nickname = &nickname
    }
    return api.Invitation{
        Id:        row.ID,
        TeamId:    row.TeamID,
        CreatedBy: createdBy,
        CreatedAt: row.CreatedAt.UTC(),
        ExpiresAt: row.ExpiresAt.UTC(),
    }
}

// userRef строит ссылку на пользователя; ник скрыт у обезличенного.
func userRef(user store.User) api.UserRef {
    ref := api.UserRef{Id: user.ID}
    if user.DeletedAt == nil {
        nickname := user.Nickname
        ref.Nickname = &nickname
    }
    return ref
}