package server

import (
	"context"
	"encoding/json"
	"errors"
	"strings"
	"unicode/utf8"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"

	"git.hakoniwa.ru/tech/himodameshi/hub/internal/api"
	"git.hakoniwa.ru/tech/himodameshi/hub/internal/store"
)

const invalidationReasonMaxLen = 500

// freqTables — таблицы частот АЧХ по версии протокола (BLE-протокол, раздел 4).
// В БД частоты не хранятся, сервер добавляет их при выдаче теста.
var freqTables = map[int][]int{
	1: {
		10, 13, 18, 24, 31, 42, 56, 74, 99, 131, 175, 232, 309, 412, 548,
		730, 1000, 1293, 1721, 2291, 3050, 4060, 5404, 7192, 9574, 12742, 16959, 22573, 30043, 40000,
	},
}

// ListCableTests отдаёт историю тестов кабеля участнику его команды.
func (s *Server) ListCableTests(ctx context.Context, request api.ListCableTestsRequestObject) (api.ListCableTestsResponseObject, error) {
	descending, limit, offset, fields := pageParams(request.Params.Order, request.Params.Limit, request.Params.Offset)
	if len(fields) > 0 {
		return nil, validationError(fields...)
	}
	if err := s.checkCableReadable(ctx, request.CableId); err != nil {
		return nil, err
	}

	total, err := s.q.CountCableTests(ctx, request.CableId)
	if err != nil {
		return nil, err
	}
	rows, err := s.q.ListCableTests(ctx, store.ListCableTestsParams{
		CableID:    request.CableId,
		Descending: descending,
		PageLimit:  limit,
		PageOffset: offset,
	})
	if err != nil {
		return nil, err
	}

	items := make([]api.Test, 0, len(rows))
	for _, row := range rows {
		test, err := toAPITest(store.GetTestDetailsRow(row))
		if err != nil {
			return nil, err
		}
		items = append(items, test)
	}
	return api.ListCableTests200JSONResponse{Items: items, Total: int(total)}, nil
}

// GetTest отдаёт тест участнику команды его кабеля вместе с ID тестов для сравнения.
func (s *Server) GetTest(ctx context.Context, request api.GetTestRequestObject) (api.GetTestResponseObject, error) {
	cableID, err := s.q.GetTestCableID(ctx, request.TestId)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, errNotFound
	}
	if err != nil {
		return nil, err
	}
	if err := s.checkCableReadable(ctx, cableID); err != nil {
		return nil, err
	}

	test, err := testDetails(ctx, s.q, request.TestId)
	if err != nil {
		return nil, err
	}
	previous, err := optionalTestID(s.q.GetPreviousValidTestID(ctx, store.GetPreviousValidTestIDParams{
		CableID:    test.CableId,
		MeasuredAt: test.MeasuredAt,
		ID:         test.Id,
	}))
	if err != nil {
		return nil, err
	}
	reference, err := optionalTestID(s.q.GetReferenceTestID(ctx, test.CableId))
	if err != nil {
		return nil, err
	}
	if reference != nil && *reference == test.Id {
		reference = nil
	}

	return api.GetTest200JSONResponse{
		AppVersion:       test.AppVersion,
		Author:           test.Author,
		CableId:          test.CableId,
		DeviceId:         test.DeviceId,
		FirmwareVersion:  test.FirmwareVersion,
		HealthIncomplete: test.HealthIncomplete,
		HealthScore:      test.HealthScore,
		Id:               test.Id,
		Insight:          test.Insight,
		Invalidation:     test.Invalidation,
		MeasuredAt:       test.MeasuredAt,
		Note:             test.Note,
		PreviousTestId:   previous,
		Pv:               test.Pv,
		ReceivedAt:       test.ReceivedAt,
		ReferenceTestId:  reference,
		Results:          test.Results,
		RulesVersion:     test.RulesVersion,
	}, nil
}

// InvalidateTest помечает тест недействительным; повтор заменяет причину вместе с автором и
// временем пометки. Повтор с той же причиной ничего не меняет.
func (s *Server) InvalidateTest(ctx context.Context, request api.InvalidateTestRequestObject) (api.InvalidateTestResponseObject, error) {
	reason := request.Body.Reason
	if strings.TrimSpace(reason) == "" || utf8.RuneCountInString(reason) > invalidationReasonMaxLen || strings.ContainsRune(reason, 0) {
		return nil, validationError(api.FieldError{Field: "reason", Message: "от 1 до 500 символов"})
	}

	userID := sessionFrom(ctx).user.ID
	now := s.now()
	result, err := s.changeTestInvalidation(ctx, request.TestId, func(test store.Test) *testInvalidationChange {
		if test.InvalidationReason != nil && *test.InvalidationReason == reason {
			return nil
		}
		return &testInvalidationChange{
			params: store.SetTestInvalidationParams{InvalidatedAt: &now, InvalidatedBy: &userID, InvalidationReason: &reason},
			event:  "test.invalidated",
			reason: reason,
		}
	})
	if err != nil {
		return nil, err
	}
	return api.InvalidateTest200JSONResponse(result), nil
}

// RevalidateTest снимает пометку «недействительный»; повтор отвечает состоянием теста.
func (s *Server) RevalidateTest(ctx context.Context, request api.RevalidateTestRequestObject) (api.RevalidateTestResponseObject, error) {
	result, err := s.changeTestInvalidation(ctx, request.TestId, func(test store.Test) *testInvalidationChange {
		if test.InvalidationReason == nil {
			return nil
		}
		return &testInvalidationChange{event: "test.revalidated", reason: *test.InvalidationReason}
	})
	if err != nil {
		return nil, err
	}
	return api.RevalidateTest200JSONResponse(result), nil
}

// testInvalidationChange — новое значение пометки и запись о нём в журнале.
type testInvalidationChange struct {
	params store.SetTestInvalidationParams
	event  string
	reason string
}

// changeTestInvalidation применяет изменение пометки к тесту действующего кабеля;
// change возвращает nil, если менять нечего.
func (s *Server) changeTestInvalidation(ctx context.Context, testID uuid.UUID, change func(store.Test) *testInvalidationChange) (api.Test, error) {
	userID := sessionFrom(ctx).user.ID
	var result api.Test
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		q := s.q.WithTx(tx)

		cableID, err := q.GetTestCableID(ctx, testID)
		if errors.Is(err, pgx.ErrNoRows) {
			return errNotFound
		}
		if err != nil {
			return err
		}
		cable, _, err := lockCable(ctx, q, cableID, userID)
		if err != nil {
			return err
		}
		if cable.ArchivedAt != nil {
			return errCableArchived
		}
		// Читается после блокировки: пока её ждали, пометку могли изменить, а тест — удалить.
		test, err := q.GetTest(ctx, testID)
		if errors.Is(err, pgx.ErrNoRows) {
			return errNotFound
		}
		if err != nil {
			return err
		}

		if c := change(test); c != nil {
			seq, err := q.AdvanceChangeSeq(ctx, store.AdvanceChangeSeqParams{ID: cable.TeamID, N: 1})
			if err != nil {
				return err
			}
			c.params.ID = test.ID
			c.params.ChangeSeq = seq
			if err := q.SetTestInvalidation(ctx, c.params); err != nil {
				return err
			}
			details, err := json.Marshal(map[string]string{"reason": c.reason})
			if err != nil {
				return err
			}
			if err := q.InsertAuditEvent(ctx, store.InsertAuditEventParams{
				TeamID:  cable.TeamID,
				ActorID: userID,
				Event:   c.event,
				CableID: &cable.ID,
				TestID:  &test.ID,
				Details: details,
			}); err != nil {
				return err
			}
		}

		result, err = testDetails(ctx, q, test.ID)
		return err
	})
	return result, err
}

func (s *Server) checkCableReadable(ctx context.Context, cableID uuid.UUID) error {
	allowed, err := s.q.CanReadCable(ctx, store.CanReadCableParams{ID: cableID, UserID: sessionFrom(ctx).user.ID})
	if err != nil {
		return err
	}
	if !allowed {
		return errNotFound
	}
	return nil
}

func testDetails(ctx context.Context, q *store.Queries, testID uuid.UUID) (api.Test, error) {
	row, err := q.GetTestDetails(ctx, testID)
	if errors.Is(err, pgx.ErrNoRows) {
		return api.Test{}, errNotFound
	}
	if err != nil {
		return api.Test{}, err
	}
	return toAPITest(row)
}

func optionalTestID(id uuid.UUID, err error) (*uuid.UUID, error) {
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	return &id, nil
}

func toAPITest(row store.GetTestDetailsRow) (api.Test, error) {
	test := row.Test
	result := api.Test{
		Id:               test.ID,
		CableId:          test.CableID,
		Author:           api.UserRef{Id: test.AuthorID},
		MeasuredAt:       test.MeasuredAt.UTC(),
		ReceivedAt:       test.ReceivedAt.UTC(),
		DeviceId:         test.DeviceID,
		Pv:               int(test.Pv),
		AppVersion:       test.AppVersion,
		RulesVersion:     test.RulesVersion,
		FirmwareVersion:  test.FirmwareVersion,
		HealthIncomplete: test.HealthIncomplete,
		Note:             test.Note,
	}
	if err := json.Unmarshal(test.Results, &result.Results); err != nil {
		return api.Test{}, err
	}
	if freq := result.Results.FreqResponse; freq != nil {
		if table, ok := freqTables[result.Pv]; ok {
			freq.F = &table
		}
	}
	if row.AuthorDeletedAt == nil {
		result.Author.Nickname = &row.AuthorNickname
	}
	if test.HealthScore != nil {
		score := int(*test.HealthScore)
		result.HealthScore = &score
	}
	if test.InvalidatedAt != nil {
		result.Invalidation = &api.Invalidation{
			At:     test.InvalidatedAt.UTC(),
			By:     api.UserRef{Id: *test.InvalidatedBy},
			Reason: *test.InvalidationReason,
		}
		if row.InvalidatorDeletedAt == nil {
			result.Invalidation.By.Nickname = row.InvalidatorNickname
		}
	}
	if test.InsightID != nil {
		result.Insight = &api.Insight{
			Id:        *test.InsightID,
			Body:      *row.InsightBody,
			Model:     *row.InsightModel,
			CreatedAt: row.InsightCreatedAt.UTC(),
		}
	}
	return result, nil
}
