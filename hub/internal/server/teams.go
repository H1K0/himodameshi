package server

import (
	"context"
	"encoding/json"
	"errors"
	"strings"
	"time"
	"unicode/utf8"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"

	"git.hakoniwa.ru/tech/himodameshi/hub/internal/api"
	"git.hakoniwa.ru/tech/himodameshi/hub/internal/config"
	"git.hakoniwa.ru/tech/himodameshi/hub/internal/store"
)

const (
	teamNameMaxLen        = 100
	teamDescriptionMaxLen = 1000
	teamRestorePeriod     = 30 * 24 * time.Hour

	roleOwner  = string(api.TeamRoleOwner)
	roleMember = string(api.TeamRoleMember)
)

// ListTeams отдаёт команды пользователя, а с deleted=true — его удалённые команды, которые ещё можно восстановить.
func (s *Server) ListTeams(ctx context.Context, request api.ListTeamsRequestObject) (api.ListTeamsResponseObject, error) {
	userID := sessionFrom(ctx).user.ID
	items := []api.Team{}

	if request.Params.Deleted != nil && *request.Params.Deleted {
		rows, err := s.q.ListDeletedOwnedTeams(ctx, store.ListDeletedOwnedTeamsParams{
			UserID:       userID,
			DeletedAfter: s.now().Add(-teamRestorePeriod),
		})
		if err != nil {
			return nil, err
		}
		for _, row := range rows {
			items = append(items, s.toAPITeam(ctx, row.Team, row.Role, row.MemberCount))
		}
		return api.ListTeams200JSONResponse{Items: items}, nil
	}

	rows, err := s.q.ListMemberTeams(ctx, userID)
	if err != nil {
		return nil, err
	}
	for _, row := range rows {
		items = append(items, s.toAPITeam(ctx, row.Team, row.Role, row.MemberCount))
	}
	return api.ListTeams200JSONResponse{Items: items}, nil
}

// CreateTeam создаёт команду; создатель становится владельцем.
func (s *Server) CreateTeam(ctx context.Context, request api.CreateTeamRequestObject) (api.CreateTeamResponseObject, error) {
	body := request.Body
	description := ""
	if body.Description != nil {
		description = *body.Description
	}
	fields := appendTeamNameError(nil, body.Name)
	fields = appendTeamDescriptionError(fields, description)
	if len(fields) > 0 {
		return nil, validationError(fields...)
	}

	userID := sessionFrom(ctx).user.ID
	var team api.Team
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		q := s.q.WithTx(tx)

		teamID, err := uuid.NewV7()
		if err != nil {
			return err
		}
		if err := q.CreateTeam(ctx, store.CreateTeamParams{ID: teamID, Name: body.Name, Description: description}); err != nil {
			return err
		}
		if err := q.AddTeamOwner(ctx, store.AddTeamOwnerParams{TeamID: teamID, UserID: userID}); err != nil {
			return err
		}
		team, err = s.memberTeam(ctx, q, teamID, userID)
		return err
	})
	if err != nil {
		return nil, err
	}
	return api.CreateTeam201JSONResponse(team), nil
}

// GetTeam отдаёт команду её участнику.
func (s *Server) GetTeam(ctx context.Context, request api.GetTeamRequestObject) (api.GetTeamResponseObject, error) {
	team, err := s.memberTeam(ctx, s.q, request.TeamId, sessionFrom(ctx).user.ID)
	if err != nil {
		return nil, err
	}
	return api.GetTeam200JSONResponse(team), nil
}

// UpdateTeam меняет название и описание; отсутствующие в запросе поля не меняются.
func (s *Server) UpdateTeam(ctx context.Context, request api.UpdateTeamRequestObject) (api.UpdateTeamResponseObject, error) {
	body := request.Body
	var fields []api.FieldError
	if body.Name != nil {
		fields = appendTeamNameError(fields, *body.Name)
	}
	if body.Description != nil {
		fields = appendTeamDescriptionError(fields, *body.Description)
	}
	if len(fields) > 0 {
		return nil, validationError(fields...)
	}

	userID := sessionFrom(ctx).user.ID
	var team api.Team
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		q := s.q.WithTx(tx)

		old, err := lockOwnedTeam(ctx, q, request.TeamId, userID)
		if err != nil {
			return err
		}

		changes := map[string]any{}
		if body.Name != nil && *body.Name != old.Name {
			changes["name"] = map[string]string{"from": old.Name, "to": *body.Name}
		}
		if body.Description != nil && *body.Description != old.Description {
			changes["description"] = map[string]string{"from": old.Description, "to": *body.Description}
		}
		if len(changes) > 0 {
			if err := q.UpdateTeam(ctx, store.UpdateTeamParams{ID: old.ID, Name: body.Name, Description: body.Description}); err != nil {
				return err
			}
			details, err := json.Marshal(changes)
			if err != nil {
				return err
			}
			if err := q.InsertAuditEvent(ctx, store.InsertAuditEventParams{
				TeamID:  old.ID,
				ActorID: userID,
				Event:   "team.updated",
				Details: details,
			}); err != nil {
				return err
			}
		}

		team, err = s.memberTeam(ctx, q, old.ID, userID)
		return err
	})
	if err != nil {
		return nil, err
	}
	return api.UpdateTeam200JSONResponse(team), nil
}

// DeleteTeam удаляет команду мягко: восстановить её можно в течение 30 суток.
func (s *Server) DeleteTeam(ctx context.Context, request api.DeleteTeamRequestObject) (api.DeleteTeamResponseObject, error) {
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		q := s.q.WithTx(tx)

		team, err := lockOwnedTeam(ctx, q, request.TeamId, sessionFrom(ctx).user.ID)
		if err != nil {
			return err
		}
		if team.IsPersonal {
			return errPersonalTeam
		}
		return q.SoftDeleteTeam(ctx, team.ID)
	})
	if err != nil {
		return nil, err
	}
	return api.DeleteTeam204Response{}, nil
}

// RestoreTeam возвращает удалённую команду.
func (s *Server) RestoreTeam(ctx context.Context, request api.RestoreTeamRequestObject) (api.RestoreTeamResponseObject, error) {
	userID := sessionFrom(ctx).user.ID
	var result api.Team
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		q := s.q.WithTx(tx)

		team, role, err := lockTeam(ctx, q, request.TeamId, userID)
		if err != nil {
			return err
		}
		if role != roleOwner {
			return errOwnerOnly
		}
		if team.DeletedAt == nil || !team.DeletedAt.After(s.now().Add(-teamRestorePeriod)) {
			return errNotFound
		}
		if err := q.RestoreTeam(ctx, team.ID); err != nil {
			return err
		}
		result, err = s.memberTeam(ctx, q, team.ID, userID)
		return err
	})
	if err != nil {
		return nil, err
	}
	return api.RestoreTeam200JSONResponse(result), nil
}

// TransferOwnership передаёт владение другому участнику; прежний владелец становится участником.
func (s *Server) TransferOwnership(ctx context.Context, request api.TransferOwnershipRequestObject) (api.TransferOwnershipResponseObject, error) {
	userID := sessionFrom(ctx).user.ID
	newOwner := request.Body.UserId
	if newOwner == userID {
		return nil, validationError(api.FieldError{Field: "user_id", Message: "вы уже владелец команды"})
	}

	var result api.Team
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		q := s.q.WithTx(tx)

		team, err := lockOwnedTeam(ctx, q, request.TeamId, userID)
		if err != nil {
			return err
		}
		if team.IsPersonal {
			return errPersonalTeam
		}
		_, err = q.GetMemberRole(ctx, store.GetMemberRoleParams{TeamID: team.ID, UserID: newOwner})
		if errors.Is(err, pgx.ErrNoRows) {
			return errNotAMember
		}
		if err != nil {
			return err
		}

		// Сначала снимается прежний владелец: индекс team_members_owner_uq не допускает двух.
		if err := q.SetMemberRole(ctx, store.SetMemberRoleParams{TeamID: team.ID, UserID: userID, Role: roleMember}); err != nil {
			return err
		}
		if err := q.SetMemberRole(ctx, store.SetMemberRoleParams{TeamID: team.ID, UserID: newOwner, Role: roleOwner}); err != nil {
			return err
		}
		details, err := json.Marshal(map[string]any{"previous_owner": userID})
		if err != nil {
			return err
		}
		if err := q.InsertAuditEvent(ctx, store.InsertAuditEventParams{
			TeamID:        team.ID,
			ActorID:       userID,
			Event:         "team.ownership_transferred",
			SubjectUserID: &newOwner,
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
	return api.TransferOwnership200JSONResponse(result), nil
}

// LeaveTeam выводит пользователя из команды.
func (s *Server) LeaveTeam(ctx context.Context, request api.LeaveTeamRequestObject) (api.LeaveTeamResponseObject, error) {
	userID := sessionFrom(ctx).user.ID
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		q := s.q.WithTx(tx)

		team, role, err := lockTeam(ctx, q, request.TeamId, userID)
		if err != nil {
			return err
		}
		if team.DeletedAt != nil {
			return errNoTeamAccess
		}
		if team.IsPersonal {
			return errPersonalTeam
		}
		if role == roleOwner {
			return errOwnerCannotLeave
		}
		return dropMember(ctx, q, team.ID, userID, userID, "member.left")
	})
	if err != nil {
		return nil, err
	}
	return api.LeaveTeam204Response{}, nil
}

// ListMembers отдаёт участников команды: владелец первым, остальные по времени вступления.
func (s *Server) ListMembers(ctx context.Context, request api.ListMembersRequestObject) (api.ListMembersResponseObject, error) {
	if _, err := s.memberTeam(ctx, s.q, request.TeamId, sessionFrom(ctx).user.ID); err != nil {
		return nil, err
	}
	rows, err := s.q.ListTeamMembers(ctx, request.TeamId)
	if err != nil {
		return nil, err
	}

	items := make([]api.Member, 0, len(rows))
	for _, row := range rows {
		ref := api.UserRef{Id: row.ID}
		if row.DeletedAt == nil {
			ref.Nickname = &row.Nickname
		}
		items = append(items, api.Member{User: ref, Role: api.TeamRole(row.Role), JoinedAt: row.JoinedAt.UTC()})
	}
	return api.ListMembers200JSONResponse{Items: items}, nil
}

// RemoveMember исключает участника команды.
func (s *Server) RemoveMember(ctx context.Context, request api.RemoveMemberRequestObject) (api.RemoveMemberResponseObject, error) {
	userID := sessionFrom(ctx).user.ID
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		q := s.q.WithTx(tx)

		team, err := lockOwnedTeam(ctx, q, request.TeamId, userID)
		if err != nil {
			return err
		}
		if request.UserId == userID {
			return errOwnerCannotLeave
		}
		_, err = q.GetMemberRole(ctx, store.GetMemberRoleParams{TeamID: team.ID, UserID: request.UserId})
		if errors.Is(err, pgx.ErrNoRows) {
			return errNotFound
		}
		if err != nil {
			return err
		}
		return dropMember(ctx, q, team.ID, request.UserId, userID, "member.removed")
	})
	if err != nil {
		return nil, err
	}
	return api.RemoveMember204Response{}, nil
}

// memberTeam отдаёт действующую команду с точки зрения её участника.
func (s *Server) memberTeam(ctx context.Context, q *store.Queries, teamID, userID uuid.UUID) (api.Team, error) {
	row, err := q.GetMemberTeam(ctx, store.GetMemberTeamParams{ID: teamID, UserID: userID})
	if errors.Is(err, pgx.ErrNoRows) {
		return api.Team{}, errNoTeamAccess
	}
	if err != nil {
		return api.Team{}, err
	}
	return s.toAPITeam(ctx, row.Team, row.Role, row.MemberCount), nil
}

// lockTeam блокирует строку команды и проверяет членство. Несуществующая команда неотличима
// от чужой. Удалённую команду не отсекает: её можно восстановить. Вызывается внутри транзакции.
func lockTeam(ctx context.Context, q *store.Queries, teamID, userID uuid.UUID) (store.Team, string, error) {
	team, err := q.LockTeam(ctx, teamID)
	if errors.Is(err, pgx.ErrNoRows) {
		return store.Team{}, "", errNoTeamAccess
	}
	if err != nil {
		return store.Team{}, "", err
	}
	role, err := q.GetMemberRole(ctx, store.GetMemberRoleParams{TeamID: teamID, UserID: userID})
	if errors.Is(err, pgx.ErrNoRows) {
		return store.Team{}, "", errNoTeamAccess
	}
	if err != nil {
		return store.Team{}, "", err
	}
	return team, role, nil
}

// lockOwnedTeam — lockTeam для действий владельца над действующей командой.
func lockOwnedTeam(ctx context.Context, q *store.Queries, teamID, userID uuid.UUID) (store.Team, error) {
	team, role, err := lockTeam(ctx, q, teamID, userID)
	if err != nil {
		return store.Team{}, err
	}
	if team.DeletedAt != nil {
		return store.Team{}, errNoTeamAccess
	}
	if role != roleOwner {
		return store.Team{}, errOwnerOnly
	}
	return team, nil
}

func (s *Server) toAPITeam(ctx context.Context, team store.Team, role string, memberCount int64) api.Team {
	result := api.Team{
		Id:          team.ID,
		Name:        team.Name,
		Description: team.Description,
		IsPersonal:  team.IsPersonal,
		Role:        api.TeamRole(role),
		Plan:        s.teamPlan(ctx, team),
		MemberCount: int(memberCount),
		CreatedAt:   team.CreatedAt.UTC(),
	}
	if team.DeletedAt != nil {
		deletedAt := team.DeletedAt.UTC()
		result.DeletedAt = &deletedAt
	}
	return result
}

// teamPlan отдаёт тариф команды; к неизвестному ключу применяются лимиты free (data-model.md, раздел 3.2).
func (s *Server) teamPlan(ctx context.Context, team store.Team) api.Plan {
	plan, ok := s.cfg.Plans[team.Plan]
	if !ok {
		s.log.WarnContext(ctx, "unknown team plan", "team_id", team.ID, "plan", team.Plan)
		return api.Plan{Key: config.FreePlan, MaxMembers: s.cfg.Plans[config.FreePlan].MaxMembers}
	}
	return api.Plan{Key: team.Plan, MaxMembers: plan.MaxMembers}
}

func appendTeamNameError(fields []api.FieldError, name string) []api.FieldError {
	if strings.TrimSpace(name) == "" || utf8.RuneCountInString(name) > teamNameMaxLen || strings.ContainsRune(name, 0) {
		return append(fields, api.FieldError{Field: "name", Message: "от 1 до 100 символов"})
	}
	return fields
}

func appendTeamDescriptionError(fields []api.FieldError, description string) []api.FieldError {
	if utf8.RuneCountInString(description) > teamDescriptionMaxLen || strings.ContainsRune(description, 0) {
		return append(fields, api.FieldError{Field: "description", Message: "не длиннее 1000 символов"})
	}
	return fields
}
