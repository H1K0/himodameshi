package server

import (
	"context"
	"encoding/json"
	"errors"
	"regexp"
	"strings"
	"time"
	"unicode/utf8"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"

	"git.hakoniwa.ru/tech/himodameshi/hub/internal/api"
	"git.hakoniwa.ru/tech/himodameshi/hub/internal/store"
)

const (
	cableNameMaxLen   = 100
	cableNoteMaxLen   = 2000
	cableSearchMaxLen = 100

	defaultPageLimit = 50
	maxPageLimit     = 100

	assigneeNone = "none"
)

var colorPattern = regexp.MustCompile(`^[0-9a-f]{6}$`)

// ListCables отдаёт каталог кабелей команды.
func (s *Server) ListCables(ctx context.Context, request api.ListCablesRequestObject) (api.ListCablesResponseObject, error) {
	filter, limit, offset, sort, descending, err := cableListParams(request.Params)
	if err != nil {
		return nil, err
	}
	if _, err := s.memberTeam(ctx, s.q, request.TeamId, sessionFrom(ctx).user.ID); err != nil {
		return nil, err
	}

	filter.TeamID = request.TeamId
	total, err := s.q.CountCables(ctx, filter)
	if err != nil {
		return nil, err
	}
	rows, err := s.q.ListCables(ctx, store.ListCablesParams{
		TeamID:     filter.TeamID,
		Archived:   filter.Archived,
		Q:          filter.Q,
		CableType:  filter.CableType,
		Color:      filter.Color,
		AssigneeID: filter.AssigneeID,
		Unassigned: filter.Unassigned,
		Health:     filter.Health,
		Sort:       sort,
		Descending: descending,
		PageLimit:  limit,
		PageOffset: offset,
	})
	if err != nil {
		return nil, err
	}

	items := make([]api.Cable, 0, len(rows))
	for _, row := range rows {
		items = append(items, toAPICable(store.GetCableDetailsRow(row)))
	}
	return api.ListCables200JSONResponse{Items: items, Total: int(total)}, nil
}

// GetCable отдаёт кабель участнику его команды.
func (s *Server) GetCable(ctx context.Context, request api.GetCableRequestObject) (api.GetCableResponseObject, error) {
	allowed, err := s.q.CanReadCable(ctx, store.CanReadCableParams{ID: request.CableId, UserID: sessionFrom(ctx).user.ID})
	if err != nil {
		return nil, err
	}
	if !allowed {
		return nil, errNotFound
	}
	cable, err := cableDetails(ctx, s.q, request.CableId)
	if err != nil {
		return nil, err
	}
	return api.GetCable200JSONResponse(cable), nil
}

// UpdateCable заменяет изменяемые атрибуты кабеля с оптимистичной блокировкой.
// Правка без изменений версию не меняет и в журнал не попадает.
func (s *Server) UpdateCable(ctx context.Context, request api.UpdateCableRequestObject) (api.UpdateCableResponseObject, error) {
	body := request.Body
	if fields := appendCableUpdateErrors(nil, body); len(fields) > 0 {
		return nil, validationError(fields...)
	}

	userID := sessionFrom(ctx).user.ID
	var result api.Cable
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		q := s.q.WithTx(tx)

		old, _, err := lockCable(ctx, q, request.CableId, userID)
		if err != nil {
			return err
		}
		if old.ArchivedAt != nil {
			return errCableArchived
		}
		if int(old.Version) != body.Version {
			current, err := cableDetails(ctx, q, old.ID)
			if err != nil {
				return err
			}
			return versionConflict(current)
		}
		if string(body.CableType) != old.CableType {
			n, err := q.CountCableTests(ctx, old.ID)
			if err != nil {
				return err
			}
			if n > 0 {
				return errCableTypeLocked
			}
		}
		if body.AssigneeId != nil {
			_, err := q.GetMemberRole(ctx, store.GetMemberRoleParams{TeamID: old.TeamID, UserID: *body.AssigneeId})
			if errors.Is(err, pgx.ErrNoRows) {
				return errNotAMember
			}
			if err != nil {
				return err
			}
		}

		changes := cableChanges(old, body)
		assigneeChanged := !sameUser(old.AssigneeID, body.AssigneeId)
		if len(changes) > 0 || assigneeChanged {
			seq, err := q.AdvanceChangeSeq(ctx, store.AdvanceChangeSeqParams{ID: old.TeamID, N: 1})
			if err != nil {
				return err
			}
			if err := q.UpdateCable(ctx, store.UpdateCableParams{
				ID:         old.ID,
				Name:       body.Name,
				CableType:  string(body.CableType),
				Color:      body.Color,
				Note:       body.Note,
				AssigneeID: body.AssigneeId,
				ChangeSeq:  seq,
			}); err != nil {
				return err
			}
		}
		if len(changes) > 0 {
			if err := insertCableEvent(ctx, q, old, userID, "cable.updated", nil, changes); err != nil {
				return err
			}
		}
		if assigneeChanged {
			// При снятии ответственного subject — тот, кого сняли, как и при выходе участника.
			subject := body.AssigneeId
			if subject == nil {
				subject = old.AssigneeID
			}
			details := map[string]any{"from": old.AssigneeID, "to": body.AssigneeId}
			if err := insertCableEvent(ctx, q, old, userID, "cable.assignee_changed", subject, details); err != nil {
				return err
			}
		}

		result, err = cableDetails(ctx, q, old.ID)
		return err
	})
	if err != nil {
		return nil, err
	}
	return api.UpdateCable200JSONResponse(result), nil
}

// DeleteCable окончательно удаляет кабель; тесты удаляются каскадом, записи журнала остаются.
func (s *Server) DeleteCable(ctx context.Context, request api.DeleteCableRequestObject) (api.DeleteCableResponseObject, error) {
	userID := sessionFrom(ctx).user.ID
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		q := s.q.WithTx(tx)

		cable, role, err := lockCable(ctx, q, request.CableId, userID)
		if err != nil {
			return err
		}
		if role != roleOwner {
			return errOwnerOnly
		}
		testCount, err := q.CountCableTests(ctx, cable.ID)
		if err != nil {
			return err
		}
		if err := q.DeleteCable(ctx, cable.ID); err != nil {
			return err
		}
		return insertCableEvent(ctx, q, cable, userID, "cable.deleted", nil, map[string]any{
			"name": cable.Name, "cable_type": cable.CableType, "test_count": testCount,
		})
	})
	if err != nil {
		return nil, err
	}
	return api.DeleteCable204Response{}, nil
}

// ArchiveCable отправляет кабель в архив; повтор отвечает его состоянием.
func (s *Server) ArchiveCable(ctx context.Context, request api.ArchiveCableRequestObject) (api.ArchiveCableResponseObject, error) {
	now := s.now()
	cable, err := s.setCableArchived(ctx, request.CableId, &now, "cable.archived")
	if err != nil {
		return nil, err
	}
	return api.ArchiveCable200JSONResponse(cable), nil
}

// UnarchiveCable возвращает кабель из архива; повтор отвечает его состоянием.
func (s *Server) UnarchiveCable(ctx context.Context, request api.UnarchiveCableRequestObject) (api.UnarchiveCableResponseObject, error) {
	cable, err := s.setCableArchived(ctx, request.CableId, nil, "cable.unarchived")
	if err != nil {
		return nil, err
	}
	return api.UnarchiveCable200JSONResponse(cable), nil
}

func (s *Server) setCableArchived(ctx context.Context, cableID uuid.UUID, archivedAt *time.Time, event string) (api.Cable, error) {
	userID := sessionFrom(ctx).user.ID
	var result api.Cable
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		q := s.q.WithTx(tx)

		cable, _, err := lockCable(ctx, q, cableID, userID)
		if err != nil {
			return err
		}
		if (cable.ArchivedAt != nil) != (archivedAt != nil) {
			seq, err := q.AdvanceChangeSeq(ctx, store.AdvanceChangeSeqParams{ID: cable.TeamID, N: 1})
			if err != nil {
				return err
			}
			if err := q.SetCableArchivedAt(ctx, store.SetCableArchivedAtParams{ID: cable.ID, ArchivedAt: archivedAt, ChangeSeq: seq}); err != nil {
				return err
			}
			if err := insertCableEvent(ctx, q, cable, userID, event, nil, map[string]any{"name": cable.Name}); err != nil {
				return err
			}
		}
		result, err = cableDetails(ctx, q, cable.ID)
		return err
	})
	return result, err
}

// lockCable блокирует строку команды кабеля и проверяет членство, поэтому изменения кабелей
// идут по очереди с изменениями состава команды. Чужой кабель и кабель удалённой команды
// неотличимы от несуществующего. Вызывается внутри транзакции.
func lockCable(ctx context.Context, q *store.Queries, cableID, userID uuid.UUID) (store.Cable, string, error) {
	teamID, err := q.GetCableTeamID(ctx, cableID)
	if errors.Is(err, pgx.ErrNoRows) {
		return store.Cable{}, "", errNotFound
	}
	if err != nil {
		return store.Cable{}, "", err
	}
	team, role, err := lockTeam(ctx, q, teamID, userID)
	if errors.Is(err, errNoTeamAccess) {
		return store.Cable{}, "", errNotFound
	}
	if err != nil {
		return store.Cable{}, "", err
	}
	if team.DeletedAt != nil {
		return store.Cable{}, "", errNotFound
	}
	// Читается после блокировки: пока её ждали, кабель могли изменить или удалить.
	cable, err := q.GetCable(ctx, cableID)
	if errors.Is(err, pgx.ErrNoRows) {
		return store.Cable{}, "", errNotFound
	}
	if err != nil {
		return store.Cable{}, "", err
	}
	return cable, role, nil
}

func cableDetails(ctx context.Context, q *store.Queries, cableID uuid.UUID) (api.Cable, error) {
	row, err := q.GetCableDetails(ctx, cableID)
	if errors.Is(err, pgx.ErrNoRows) {
		return api.Cable{}, errNotFound
	}
	if err != nil {
		return api.Cable{}, err
	}
	return toAPICable(row), nil
}

func insertCableEvent(ctx context.Context, q *store.Queries, cable store.Cable, actorID uuid.UUID, event string, subject *uuid.UUID, details map[string]any) error {
	data, err := json.Marshal(details)
	if err != nil {
		return err
	}
	return q.InsertAuditEvent(ctx, store.InsertAuditEventParams{
		TeamID:        cable.TeamID,
		ActorID:       actorID,
		Event:         event,
		CableID:       &cable.ID,
		SubjectUserID: subject,
		Details:       data,
	})
}

// cableChanges собирает «было / стало» по изменённым атрибутам, кроме ответственного:
// у него своё событие в журнале.
func cableChanges(old store.Cable, body *api.UpdateCableJSONRequestBody) map[string]any {
	changes := map[string]any{}
	if body.Name != old.Name {
		changes["name"] = map[string]string{"from": old.Name, "to": body.Name}
	}
	if string(body.CableType) != old.CableType {
		changes["cable_type"] = map[string]string{"from": old.CableType, "to": string(body.CableType)}
	}
	if body.Color != old.Color {
		changes["color"] = map[string]string{"from": old.Color, "to": body.Color}
	}
	if !sameString(old.Note, body.Note) {
		changes["note"] = map[string]*string{"from": old.Note, "to": body.Note}
	}
	return changes
}

func sameString(a, b *string) bool {
	return a == b || (a != nil && b != nil && *a == *b)
}

func sameUser(a, b *uuid.UUID) bool {
	return a == b || (a != nil && b != nil && *a == *b)
}

func toAPICable(row store.GetCableDetailsRow) api.Cable {
	cable := row.Cable
	result := api.Cable{
		Id:         cable.ID,
		TeamId:     cable.TeamID,
		Name:       cable.Name,
		CableType:  api.CableType(cable.CableType),
		Color:      cable.Color,
		Note:       cable.Note,
		CreatedBy:  api.UserRef{Id: cable.CreatedBy},
		CreatedAt:  cable.CreatedAt.UTC(),
		UpdatedAt:  cable.UpdatedAt.UTC(),
		Version:    int(cable.Version),
		ArchivedAt: utcTime(cable.ArchivedAt),
		TestCount:  int(row.TestCount),
	}
	// Для max() sqlc не выводит тип: приходит time.Time или nil, если тестов нет.
	if lastTestAt, ok := row.LastTestAt.(time.Time); ok {
		result.LastTestAt = utcTime(&lastTestAt)
	}
	if row.CreatorDeletedAt == nil {
		result.CreatedBy.Nickname = &row.CreatorNickname
	}
	if cable.AssigneeID != nil {
		result.Assignee = &api.UserRef{Id: *cable.AssigneeID}
		if row.AssigneeDeletedAt == nil {
			result.Assignee.Nickname = row.AssigneeNickname
		}
	}
	if row.HealthScore != nil {
		score := int(*row.HealthScore)
		result.HealthScore = &score
	}
	return result
}

func utcTime(t *time.Time) *time.Time {
	if t == nil {
		return nil
	}
	utc := t.UTC()
	return &utc
}

// cableListParams проверяет параметры каталога и подставляет значения по умолчанию.
func cableListParams(params api.ListCablesParams) (filter store.CountCablesParams, limit, offset int64, sort string, descending bool, err error) {
	var fields []api.FieldError
	invalid := func(field, message string) {
		fields = append(fields, api.FieldError{Field: field, Message: message})
	}

	if params.Q != nil {
		if utf8.RuneCountInString(*params.Q) > cableSearchMaxLen || strings.ContainsRune(*params.Q, 0) {
			invalid("q", "не длиннее 100 символов")
		}
		filter.Q = params.Q
	}
	if params.CableType != nil {
		if !validCableType(*params.CableType) {
			invalid("cable_type", "ожидается jack_ts, jack_trs или xlr")
		}
		cableType := string(*params.CableType)
		filter.CableType = &cableType
	}
	if params.Color != nil {
		if !colorPattern.MatchString(*params.Color) {
			invalid("color", "ожидается hex без # в нижнем регистре")
		}
		filter.Color = params.Color
	}
	if params.Health != nil {
		switch *params.Health {
		case api.Green, api.Yellow, api.Red, api.None:
		default:
			invalid("health", "ожидается green, yellow, red или none")
		}
		health := string(*params.Health)
		filter.Health = &health
	}
	if params.Assignee != nil {
		if *params.Assignee == assigneeNone {
			filter.Unassigned = true
		} else if id, err := uuid.Parse(*params.Assignee); err == nil {
			filter.AssigneeID = &id
		} else {
			invalid("assignee", "ожидается ID пользователя или none")
		}
	}
	if params.Archived != nil {
		filter.Archived = *params.Archived
	}

	sort = string(api.LastTestAt)
	if params.Sort != nil {
		switch *params.Sort {
		case api.LastTestAt, api.Name, api.HealthScore:
		default:
			invalid("sort", "ожидается last_test_at, name или health_score")
		}
		sort = string(*params.Sort)
	}
	descending, limit, offset, pageFields := pageParams(params.Order, params.Limit, params.Offset)
	fields = append(fields, pageFields...)

	if len(fields) > 0 {
		err = validationError(fields...)
	}
	return filter, limit, offset, sort, descending, err
}

// pageParams проверяет порядок и параметры страницы и подставляет значения по умолчанию.
func pageParams(order *api.SortOrder, limit, offset *int) (descending bool, pageLimit, pageOffset int64, fields []api.FieldError) {
	invalid := func(field, message string) {
		fields = append(fields, api.FieldError{Field: field, Message: message})
	}

	descending = true
	if order != nil {
		switch *order {
		case api.Asc:
			descending = false
		case api.Desc:
		default:
			invalid("order", "ожидается asc или desc")
		}
	}

	pageLimit = defaultPageLimit
	if limit != nil {
		if *limit < 1 || *limit > maxPageLimit {
			invalid("limit", "от 1 до 100")
		}
		pageLimit = int64(*limit)
	}
	if offset != nil {
		if *offset < 0 {
			invalid("offset", "не меньше 0")
		}
		pageOffset = int64(*offset)
	}
	return descending, pageLimit, pageOffset, fields
}

func validCableType(cableType api.CableType) bool {
	switch cableType {
	case api.JackTs, api.JackTrs, api.Xlr:
		return true
	}
	return false
}

func appendCableUpdateErrors(fields []api.FieldError, body *api.UpdateCableJSONRequestBody) []api.FieldError {
	if body.Version < 1 {
		fields = append(fields, api.FieldError{Field: "version", Message: "ожидается версия кабеля"})
	}
	if strings.TrimSpace(body.Name) == "" || utf8.RuneCountInString(body.Name) > cableNameMaxLen || strings.ContainsRune(body.Name, 0) {
		fields = append(fields, api.FieldError{Field: "name", Message: "от 1 до 100 символов"})
	}
	if !validCableType(body.CableType) {
		fields = append(fields, api.FieldError{Field: "cable_type", Message: "ожидается jack_ts, jack_trs или xlr"})
	}
	if !colorPattern.MatchString(body.Color) {
		fields = append(fields, api.FieldError{Field: "color", Message: "ожидается hex без # в нижнем регистре"})
	}
	if body.Note != nil && (utf8.RuneCountInString(*body.Note) > cableNoteMaxLen || strings.ContainsRune(*body.Note, 0)) {
		fields = append(fields, api.FieldError{Field: "note", Message: "не длиннее 2000 символов"})
	}
	return fields
}
