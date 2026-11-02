package server

import (
	"context"
	"encoding/json"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"

	"git.hakoniwa.ru/tech/himodameshi/hub/internal/api"
	"git.hakoniwa.ru/tech/himodameshi/hub/internal/auth"
	"git.hakoniwa.ru/tech/himodameshi/hub/internal/store"
)

// GetMe отдаёт профиль текущего пользователя.
func (s *Server) GetMe(ctx context.Context, _ api.GetMeRequestObject) (api.GetMeResponseObject, error) {
	return api.GetMe200JSONResponse(toAPIUser(sessionFrom(ctx).user)), nil
}

// UpdateMe меняет ник.
func (s *Server) UpdateMe(ctx context.Context, request api.UpdateMeRequestObject) (api.UpdateMeResponseObject, error) {
	if fields := appendNicknameError(nil, "nickname", request.Body.Nickname); len(fields) > 0 {
		return nil, validationError(fields...)
	}

	user, err := s.q.UpdateNickname(ctx, store.UpdateNicknameParams{
		ID:       sessionFrom(ctx).user.ID,
		Nickname: request.Body.Nickname,
	})
	if isUniqueViolation(err, nicknameConstraint) {
		return nil, errNicknameTaken
	}
	if err != nil {
		return nil, err
	}
	return api.UpdateMe200JSONResponse(toAPIUser(user)), nil
}

// DeleteMe обезличивает учётную запись.
func (s *Server) DeleteMe(ctx context.Context, _ api.DeleteMeRequestObject) (api.DeleteMeResponseObject, error) {
	session := sessionFrom(ctx)
	userID := session.user.ID

	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		q := s.q.WithTx(tx)

		blocking, err := q.CountOwnedTeamsWithMembers(ctx, userID)
		if err != nil {
			return err
		}
		if blocking > 0 {
			return errOwnerWithMembers
		}

		// Остальные команды, которыми он владеет, без владельца не нужны никому.
		if err := q.DeleteOwnedTeams(ctx, userID); err != nil {
			return err
		}
		teamIDs, err := q.ListMemberTeamIDs(ctx, userID)
		if err != nil {
			return err
		}
		for _, teamID := range teamIDs {
			if err := leaveTeam(ctx, q, teamID, userID); err != nil {
				return err
			}
		}

		if err := q.AnonymizeUser(ctx, userID); err != nil {
			return err
		}
		return q.DeleteUserSessions(ctx, userID)
	})
	if err != nil {
		return nil, err
	}

	s.logSecurity(ctx, "account_deleted", "user_id", userID)
	return noContentResponse{clearCookie: session.viaCookie}, nil
}

// leaveTeam убирает участника из команды и сбрасывает его как ответственного
// (data-model.md, раздел 3.2). Вызывается внутри транзакции.
func leaveTeam(ctx context.Context, q *store.Queries, teamID, userID uuid.UUID) error {
	cableIDs, err := q.ListAssignedCableIDs(ctx, store.ListAssignedCableIDsParams{TeamID: teamID, UserID: &userID})
	if err != nil {
		return err
	}

	if len(cableIDs) > 0 {
		n := int64(len(cableIDs))
		last, err := q.AdvanceChangeSeq(ctx, store.AdvanceChangeSeqParams{ID: teamID, N: n})
		if err != nil {
			return err
		}
		details, err := json.Marshal(map[string]any{"from": userID, "to": nil})
		if err != nil {
			return err
		}
		for i, cableID := range cableIDs {
			if err := q.ClearCableAssignee(ctx, store.ClearCableAssigneeParams{
				ID:        cableID,
				ChangeSeq: last - n + int64(i) + 1,
			}); err != nil {
				return err
			}
			if err := q.InsertAuditEvent(ctx, store.InsertAuditEventParams{
				TeamID:        teamID,
				ActorID:       userID,
				Event:         "cable.assignee_changed",
				CableID:       &cableID,
				SubjectUserID: &userID,
				Details:       details,
			}); err != nil {
				return err
			}
		}
	}

	if err := q.RemoveTeamMember(ctx, store.RemoveTeamMemberParams{TeamID: teamID, UserID: userID}); err != nil {
		return err
	}
	return q.InsertAuditEvent(ctx, store.InsertAuditEventParams{
		TeamID:        teamID,
		ActorID:       userID,
		Event:         "member.left",
		SubjectUserID: &userID,
		Details:       []byte("{}"),
	})
}

// ChangePassword меняет пароль и завершает все сеансы, кроме текущего.
func (s *Server) ChangePassword(ctx context.Context, request api.ChangePasswordRequestObject) (api.ChangePasswordResponseObject, error) {
	session := sessionFrom(ctx)
	body := request.Body

	if fields := appendPasswordError(nil, "new_password", body.NewPassword); len(fields) > 0 {
		return nil, validationError(fields...)
	}
	// Заведомо неверный по длине пароль не хешируется: длинная строка стоила бы лишнего времени.
	if !validPasswordLength(body.CurrentPassword) || session.user.PasswordHash == nil {
		return nil, errWrongPassword
	}
	match, err := auth.VerifyPassword(*session.user.PasswordHash, body.CurrentPassword)
	if err != nil {
		return nil, err
	}
	if !match {
		s.logSecurity(ctx, "password_change_failed", "user_id", session.user.ID)
		return nil, errWrongPassword
	}

	hash, err := auth.HashPassword(body.NewPassword)
	if err != nil {
		return nil, err
	}
	err = pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		q := s.q.WithTx(tx)
		if err := q.UpdatePasswordHash(ctx, store.UpdatePasswordHashParams{ID: session.user.ID, PasswordHash: &hash}); err != nil {
			return err
		}
		return q.RevokeOtherSessions(ctx, store.RevokeOtherSessionsParams{UserID: session.user.ID, KeepID: session.id})
	})
	if err != nil {
		return nil, err
	}

	s.logSecurity(ctx, "password_changed", "user_id", session.user.ID)
	return api.ChangePassword204Response{}, nil
}

// LinkTelegram привязывает Telegram к учётной записи.
func (s *Server) LinkTelegram(ctx context.Context, request api.LinkTelegramRequestObject) (api.LinkTelegramResponseObject, error) {
	if err := s.checkTelegram(ctx, request.Body); err != nil {
		return nil, err
	}

	session := sessionFrom(ctx)
	user, err := s.q.SetTelegram(ctx, store.SetTelegramParams{
		ID:               session.user.ID,
		TelegramID:       &request.Body.Id,
		TelegramUsername: request.Body.Username,
	})
	if isUniqueViolation(err, telegramIDConstrain) {
		return nil, errTelegramTaken
	}
	if err != nil {
		return nil, err
	}

	s.logSecurity(ctx, "telegram_linked", "user_id", user.ID)
	return api.LinkTelegram200JSONResponse(toAPIUser(user)), nil
}

// UnlinkTelegram отвязывает Telegram.
func (s *Server) UnlinkTelegram(ctx context.Context, _ api.UnlinkTelegramRequestObject) (api.UnlinkTelegramResponseObject, error) {
	session := sessionFrom(ctx)
	if err := s.q.ClearTelegram(ctx, session.user.ID); err != nil {
		return nil, err
	}
	s.logSecurity(ctx, "telegram_unlinked", "user_id", session.user.ID)
	return api.UnlinkTelegram204Response{}, nil
}
