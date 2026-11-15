package server

import (
	"bytes"
	"context"
	"crypto/sha256"
	"encoding/json"
	"errors"
	"slices"
	"strconv"
	"strings"
	"unicode/utf8"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"

	"git.hakoniwa.ru/tech/himodameshi/hub/internal/api"
	"git.hakoniwa.ru/tech/himodameshi/hub/internal/store"
)

// Протокол синхронизации — docs/spec/hub/sync.md, серверная сторона — data-model.md, раздел 5.
const (
	pushMaxItems  = 100
	pullPageTests = 100
	pullMaxCables = 1000

	testDeviceIDMaxLen = 64
	testVersionMaxLen  = 32
	testNoteMaxLen     = 2000
)

// cableConductors — проводники целостности по типу кабеля (data-model.md, раздел 4).
var cableConductors = map[string][]string{
	string(api.JackTs):  {"tip", "sleeve"},
	string(api.JackTrs): {"tip", "ring", "sleeve"},
	string(api.Xlr):     {"pin1", "pin2", "pin3"},
}

// SyncPush принимает пакет новых кабелей, правок и тестов. Пакет — одна транзакция,
// у каждого объекта своя точка сохранения: отказ по объекту откатывает только его.
func (s *Server) SyncPush(ctx context.Context, request api.SyncPushRequestObject) (api.SyncPushResponseObject, error) {
	body := request.Body
	if len(body.Cables)+len(body.CableUpdates)+len(body.Tests) > pushMaxItems {
		return nil, validationError(api.FieldError{Field: "body", Message: "не больше 100 объектов в сумме"})
	}

	var result api.SyncPush200JSONResponse
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		result = api.SyncPush200JSONResponse{
			Cables:       make([]api.PushCableResult, 0, len(body.Cables)),
			CableUpdates: make([]api.PushCableResult, 0, len(body.CableUpdates)),
			Tests:        make([]api.PushTestResult, 0, len(body.Tests)),
		}
		p, err := s.startPush(ctx, tx, sessionFrom(ctx).user.ID, body)
		if err != nil {
			return err
		}

		for _, item := range body.Cables {
			var cable api.Cable
			rejected, err := p.item(ctx, func(q *store.Queries) (err error) {
				cable, err = p.createCable(ctx, q, item)
				return err
			})
			if err != nil {
				return err
			}
			result.Cables = append(result.Cables, cableResult(item.Id, cable, rejected))
		}
		for _, item := range body.CableUpdates {
			var cable api.Cable
			rejected, err := p.item(ctx, func(q *store.Queries) (err error) {
				cable, err = p.updateCable(ctx, q, item)
				return err
			})
			if err != nil {
				return err
			}
			result.CableUpdates = append(result.CableUpdates, cableResult(item.Id, cable, rejected))
		}
		for _, item := range body.Tests {
			rejected, err := p.item(ctx, func(q *store.Queries) error {
				return p.uploadTest(ctx, q, item)
			})
			if err != nil {
				return err
			}
			test := api.PushTestResult{Id: item.Id, Status: api.Accepted}
			if rejected != nil {
				test.Status = api.Rejected
				test.Error = itemError(rejected)
			}
			result.Tests = append(result.Tests, test)
		}
		return nil
	})
	if err != nil {
		return nil, err
	}
	return result, nil
}

// SyncPull отдаёт изменения отслеживаемых кабелей команды после курсора. Все запросы
// идут по одному снимку БД, поэтому кабели, тесты, удалённые кабели и курсор согласованы.
func (s *Server) SyncPull(ctx context.Context, request api.SyncPullRequestObject) (api.SyncPullResponseObject, error) {
	body := request.Body
	var fields []api.FieldError
	if body.Cursor < 0 {
		fields = append(fields, api.FieldError{Field: "cursor", Message: "не меньше 0"})
	}
	if len(body.Cables) < 1 || len(body.Cables) > pullMaxCables {
		fields = append(fields, api.FieldError{Field: "cables", Message: "от 1 до 1000 кабелей"})
	}
	if len(fields) > 0 {
		return nil, validationError(fields...)
	}
	ids := slices.Clone(body.Cables)
	slices.SortFunc(ids, func(a, b uuid.UUID) int { return bytes.Compare(a[:], b[:]) })
	ids = slices.Compact(ids)

	userID := sessionFrom(ctx).user.ID
	var result api.SyncPull200JSONResponse
	opts := pgx.TxOptions{IsoLevel: pgx.RepeatableRead, AccessMode: pgx.ReadOnly}
	err := pgx.BeginTxFunc(ctx, s.db, opts, func(tx pgx.Tx) error {
		q := s.q.WithTx(tx)

		team, err := q.GetMemberTeam(ctx, store.GetMemberTeamParams{ID: body.TeamId, UserID: userID})
		if errors.Is(err, pgx.ErrNoRows) {
			return errNoTeamAccess
		}
		if err != nil {
			return err
		}

		testRows, err := q.ListSyncTests(ctx, store.ListSyncTestsParams{
			TeamID:    body.TeamId,
			Ids:       ids,
			AfterSeq:  body.Cursor,
			PageLimit: pullPageTests + 1,
		})
		if err != nil {
			return err
		}
		// Без продолжения курсор — счётчик команды; иначе — номер последнего отданного теста,
		// и кабели берутся только до него: остальные придут со следующей страницей.
		cursor := team.Team.ChangeSeq
		hasMore := len(testRows) > pullPageTests
		if hasMore {
			testRows = testRows[:pullPageTests]
			cursor = testRows[len(testRows)-1].Test.ChangeSeq
		}

		cableRows, err := q.ListSyncCables(ctx, store.ListSyncCablesParams{
			TeamID:   body.TeamId,
			Ids:      ids,
			AfterSeq: body.Cursor,
			UptoSeq:  cursor,
		})
		if err != nil {
			return err
		}
		deleted, err := q.ListMissingCables(ctx, store.ListMissingCablesParams{TeamID: body.TeamId, Ids: ids})
		if err != nil {
			return err
		}

		result = api.SyncPull200JSONResponse{
			Cables:        make([]api.Cable, 0, len(cableRows)),
			Tests:         make([]api.Test, 0, len(testRows)),
			DeletedCables: deleted,
			Cursor:        cursor,
			HasMore:       hasMore,
		}
		if result.DeletedCables == nil {
			result.DeletedCables = []api.Uuid{}
		}
		for _, row := range cableRows {
			result.Cables = append(result.Cables, toAPICable(store.GetCableDetailsRow(row)))
		}
		for _, row := range testRows {
			test, err := toAPITest(store.GetTestDetailsRow(row))
			if err != nil {
				return err
			}
			result.Tests = append(result.Tests, test)
		}
		return nil
	})
	if err != nil {
		return nil, err
	}
	return result, nil
}

// push — состояние обработки одного пакета выгрузки.
type push struct {
	tx     pgx.Tx
	q      *store.Queries
	userID uuid.UUID
	// Заблокированные команды пакета: true — пользователь участник действующей команды.
	teams map[uuid.UUID]bool
}

// startPush заранее блокирует все команды пакета одним запросом в порядке ID,
// чтобы два пакета не заблокировали друг друга (data-model.md, раздел 5.3).
func (s *Server) startPush(ctx context.Context, tx pgx.Tx, userID uuid.UUID, body *api.PushRequest) (*push, error) {
	q := s.q.WithTx(tx)

	teamIDs := make([]uuid.UUID, 0, len(body.Cables))
	for _, cable := range body.Cables {
		teamIDs = append(teamIDs, cable.TeamId)
	}
	cableIDs := make([]uuid.UUID, 0, len(body.CableUpdates)+len(body.Tests))
	for _, update := range body.CableUpdates {
		cableIDs = append(cableIDs, update.Id)
	}
	for _, test := range body.Tests {
		cableIDs = append(cableIDs, test.CableId)
	}
	rows, err := q.ListCableTeams(ctx, cableIDs)
	if err != nil {
		return nil, err
	}
	for _, row := range rows {
		teamIDs = append(teamIDs, row.TeamID)
	}

	locked, err := q.LockTeams(ctx, teamIDs)
	if err != nil {
		return nil, err
	}
	accessible, err := q.ListAccessibleTeamIDs(ctx, store.ListAccessibleTeamIDsParams{UserID: userID, Ids: locked})
	if err != nil {
		return nil, err
	}
	p := &push{tx: tx, q: q, userID: userID, teams: make(map[uuid.UUID]bool, len(locked))}
	for _, id := range locked {
		p.teams[id] = false
	}
	for _, id := range accessible {
		p.teams[id] = true
	}
	return p, nil
}

// item обрабатывает один объект в своей точке сохранения. Отказ по объекту (*problem)
// откатывает только его и возвращается первым значением; прочие ошибки прерывают пакет.
func (p *push) item(ctx context.Context, fn func(q *store.Queries) error) (*problem, error) {
	err := pgx.BeginFunc(ctx, p.tx, func(sp pgx.Tx) error {
		return fn(p.q.WithTx(sp))
	})
	var rejected *problem
	if errors.As(err, &rejected) {
		return rejected, nil
	}
	return nil, err
}

// access проверяет, что пользователь — участник действующей команды. Команду, которой не было
// среди заблокированных в начале пакета (кабель появился позже), блокирует здесь.
func (p *push) access(ctx context.Context, q *store.Queries, teamID uuid.UUID) error {
	member, ok := p.teams[teamID]
	if !ok {
		team, _, err := lockTeam(ctx, q, teamID, p.userID)
		switch {
		case errors.Is(err, errNoTeamAccess):
		case err != nil:
			return err
		default:
			member = team.DeletedAt == nil
		}
		p.teams[teamID] = member
	}
	if !member {
		return errNoTeamAccess
	}
	return nil
}

// cable читает кабель пакета после проверки доступа к его команде.
func (p *push) cable(ctx context.Context, q *store.Queries, cableID uuid.UUID) (store.Cable, error) {
	teamID, err := q.GetCableTeamID(ctx, cableID)
	if errors.Is(err, pgx.ErrNoRows) {
		return store.Cable{}, errCableNotFound
	}
	if err != nil {
		return store.Cable{}, err
	}
	if err := p.access(ctx, q, teamID); err != nil {
		return store.Cable{}, err
	}
	// Читается после блокировки команды: кабель могли изменить или удалить.
	cable, err := q.GetCable(ctx, cableID)
	if errors.Is(err, pgx.ErrNoRows) {
		return store.Cable{}, errCableNotFound
	}
	return cable, err
}

// createCable создаёт кабель. Повтор с тем же ID в той же команде принимается
// и отдаёт актуальное состояние кабеля, в другой команде — id_conflict.
func (p *push) createCable(ctx context.Context, q *store.Queries, item api.NewCable) (api.Cable, error) {
	fields := appendCableAttrErrors(nil, item.Name, item.CableType, item.Color, item.Note)
	if item.CreatedAt.IsZero() {
		fields = append(fields, api.FieldError{Field: "created_at", Message: "ожидается время создания"})
	}
	if len(fields) > 0 {
		return api.Cable{}, validationError(fields...)
	}
	if err := p.access(ctx, q, item.TeamId); err != nil {
		return api.Cable{}, err
	}

	teamID, err := q.GetCableTeamID(ctx, item.Id)
	if err == nil {
		if teamID != item.TeamId {
			return api.Cable{}, errIDConflict
		}
		return cableDetails(ctx, q, item.Id)
	}
	if !errors.Is(err, pgx.ErrNoRows) {
		return api.Cable{}, err
	}

	seq, err := q.AdvanceChangeSeq(ctx, store.AdvanceChangeSeqParams{ID: item.TeamId, N: 1})
	if err != nil {
		return api.Cable{}, err
	}
	n, err := q.InsertCable(ctx, store.InsertCableParams{
		ID:        item.Id,
		TeamID:    item.TeamId,
		Name:      item.Name,
		CableType: string(item.CableType),
		Color:     item.Color,
		Note:      item.Note,
		CreatedBy: p.userID,
		CreatedAt: item.CreatedAt,
		ChangeSeq: seq,
	})
	if err != nil {
		return api.Cable{}, err
	}
	if n == 0 {
		return api.Cable{}, errIDConflict
	}
	cable := store.Cable{ID: item.Id, TeamID: item.TeamId}
	details := map[string]any{"name": item.Name, "cable_type": item.CableType}
	if err := insertCableEvent(ctx, q, cable, p.userID, "cable.created", nil, details); err != nil {
		return api.Cable{}, err
	}
	return cableDetails(ctx, q, item.Id)
}

// updateCable применяет правку атрибутов так же, как PUT /cables/{id}.
func (p *push) updateCable(ctx context.Context, q *store.Queries, item api.CableUpdateItem) (api.Cable, error) {
	body := api.CableUpdate{
		Version:    item.Version,
		Name:       item.Name,
		CableType:  item.CableType,
		Color:      item.Color,
		Note:       item.Note,
		AssigneeId: item.AssigneeId,
	}
	if fields := appendCableUpdateErrors(nil, &body); len(fields) > 0 {
		return api.Cable{}, validationError(fields...)
	}
	cable, err := p.cable(ctx, q, item.Id)
	if err != nil {
		return api.Cable{}, err
	}
	return applyCableUpdate(ctx, q, cable, p.userID, &body)
}

// uploadTest сохраняет тест. Повтор с тем же ID и содержимым принимается снова,
// с другим содержимым — id_conflict (data-model.md, раздел 5.3).
func (p *push) uploadTest(ctx context.Context, q *store.Queries, item api.NewTest) error {
	// Частоты АЧХ добавляет сервер при выдаче, в БД они не хранятся.
	if item.Results.FreqResponse != nil {
		item.Results.FreqResponse.F = nil
	}
	item.MeasuredAt = item.MeasuredAt.UTC()
	results, err := json.Marshal(item.Results)
	if err != nil {
		return err
	}
	if fields := testMetaErrors(item, results); len(fields) > 0 {
		return validationError(fields...)
	}

	cable, err := p.cable(ctx, q, item.CableId)
	if err != nil {
		return err
	}
	// Хеш считается по всему, что прислало приложение, включая ID кабеля.
	payload, err := json.Marshal(item)
	if err != nil {
		return err
	}
	hash := sha256.Sum256(payload)

	existing, err := q.GetTest(ctx, item.Id)
	if err == nil {
		if !bytes.Equal(existing.PayloadHash, hash[:]) {
			return errIDConflict
		}
		return nil
	}
	if !errors.Is(err, pgx.ErrNoRows) {
		return err
	}
	if cable.ArchivedAt != nil {
		return errCableArchived
	}
	if fields := testResultErrors(item.Results, cable.CableType, item.Pv); len(fields) > 0 {
		return validationError(fields...)
	}

	seq, err := q.AdvanceChangeSeq(ctx, store.AdvanceChangeSeqParams{ID: cable.TeamID, N: 1})
	if err != nil {
		return err
	}
	var healthScore *int16
	if item.HealthScore != nil {
		score := int16(*item.HealthScore)
		healthScore = &score
	}
	n, err := q.InsertTest(ctx, store.InsertTestParams{
		ID:               item.Id,
		CableID:          cable.ID,
		AuthorID:         p.userID,
		MeasuredAt:       item.MeasuredAt,
		DeviceID:         item.DeviceId,
		Pv:               int16(item.Pv),
		AppVersion:       item.AppVersion,
		RulesVersion:     item.RulesVersion,
		FirmwareVersion:  item.FirmwareVersion,
		HealthScore:      healthScore,
		HealthIncomplete: item.HealthIncomplete,
		Note:             item.Note,
		Results:          results,
		PayloadHash:      hash[:],
		ChangeSeq:        seq,
	})
	if err != nil {
		return err
	}
	if n == 0 {
		// Тест с таким ID появился в другой команде, пока шла проверка.
		return errIDConflict
	}

	details, err := json.Marshal(map[string]any{
		"name": cable.Name, "measured_at": item.MeasuredAt, "health_score": item.HealthScore,
	})
	if err != nil {
		return err
	}
	return q.InsertAuditEvent(ctx, store.InsertAuditEventParams{
		TeamID:  cable.TeamID,
		ActorID: p.userID,
		Event:   "test.uploaded",
		CableID: &cable.ID,
		TestID:  &item.Id,
		Details: details,
	})
}

func cableResult(id uuid.UUID, cable api.Cable, rejected *problem) api.PushCableResult {
	if rejected != nil {
		// Актуальный кабель в отказе есть только при version_conflict.
		return api.PushCableResult{Id: id, Status: api.Rejected, Error: itemError(rejected), Cable: rejected.cable}
	}
	return api.PushCableResult{Id: id, Status: api.Accepted, Cable: &cable}
}

func itemError(p *problem) *api.ItemError {
	result := &api.ItemError{Code: p.code}
	detail := p.detail
	if len(p.fields) > 0 {
		parts := make([]string, 0, len(p.fields))
		for _, field := range p.fields {
			parts = append(parts, field.Field+": "+field.Message)
		}
		detail = strings.Join(parts, "; ")
	}
	if detail != "" {
		result.Detail = &detail
	}
	return result
}

// testMetaErrors проверяет поля теста, не зависящие от кабеля.
func testMetaErrors(item api.NewTest, results []byte) []api.FieldError {
	var fields []api.FieldError
	invalid := func(field, message string) {
		fields = append(fields, api.FieldError{Field: field, Message: message})
	}
	text := func(s string, maxLen int) bool {
		return s != "" && utf8.RuneCountInString(s) <= maxLen && !strings.ContainsRune(s, 0)
	}
	optionalText := func(s *string, maxLen int) bool {
		return s == nil || utf8.RuneCountInString(*s) <= maxLen && !strings.ContainsRune(*s, 0)
	}

	if item.MeasuredAt.IsZero() {
		invalid("measured_at", "ожидается время измерения")
	}
	if !text(item.DeviceId, testDeviceIDMaxLen) {
		invalid("device_id", "от 1 до 64 символов")
	}
	if _, ok := freqTables[item.Pv]; !ok {
		invalid("pv", "неподдерживаемая версия протокола")
	}
	if !text(item.AppVersion, testVersionMaxLen) {
		invalid("app_version", "от 1 до 32 символов")
	}
	if !text(item.RulesVersion, testVersionMaxLen) {
		invalid("rules_version", "от 1 до 32 символов")
	}
	if !optionalText(item.FirmwareVersion, testVersionMaxLen) {
		invalid("firmware_version", "не длиннее 32 символов")
	}
	if item.HealthScore != nil && (*item.HealthScore < 0 || *item.HealthScore > 100) {
		invalid("health_score", "от 0 до 100")
	}
	if !optionalText(item.Note, testNoteMaxLen) {
		invalid("note", "не длиннее 2000 символов")
	}
	r := item.Results
	switch {
	case r.Continuity == nil && r.Cmrr == nil && r.FreqResponse == nil:
		invalid("results", "ожидается хотя бы одно измерение")
	case bytes.Contains(results, []byte(`\u0000`)):
		// PostgreSQL не хранит символ NUL в jsonb.
		invalid("results", "недопустимый символ NUL")
	}
	return fields
}

// testResultErrors проверяет структуру результатов по типу кабеля (data-model.md, раздел 4).
func testResultErrors(r api.TestResults, cableType string, pv int) []api.FieldError {
	var fields []api.FieldError
	invalid := func(field, message string) {
		fields = append(fields, api.FieldError{Field: "results." + field, Message: message})
	}

	if c := r.Continuity; c != nil {
		switch c.Status {
		case api.ContinuityStatusOk, api.ContinuityStatusWarning, api.ContinuityStatusFail:
		default:
			invalid("continuity.status", "ожидается ok, warning или fail")
		}
		conductors := []struct {
			name      string
			conductor *api.Conductor
		}{
			{"tip", c.Conductors.Tip},
			{"ring", c.Conductors.Ring},
			{"sleeve", c.Conductors.Sleeve},
			{"pin1", c.Conductors.Pin1},
			{"pin2", c.Conductors.Pin2},
			{"pin3", c.Conductors.Pin3},
		}
		want := cableConductors[cableType]
		for _, item := range conductors {
			if (item.conductor != nil) != slices.Contains(want, item.name) {
				invalid("continuity.conductors", "для "+cableType+" ожидаются "+strings.Join(want, ", "))
				break
			}
		}
		for _, item := range conductors {
			if item.conductor == nil {
				continue
			}
			if item.conductor.R < 0 || item.conductor.R > 1e6 {
				invalid("continuity.conductors."+item.name+".r", "от 0 до 1000000")
			}
			switch item.conductor.S {
			case api.ConductorStatusOk, api.ConductorStatusWarning, api.ConductorStatusOpen, api.ConductorStatusShort:
			default:
				invalid("continuity.conductors."+item.name+".s", "ожидается ok, warning, open или short")
			}
		}
	}

	if c := r.Cmrr; c != nil {
		if cableType == string(api.JackTs) {
			invalid("cmrr", "у jack_ts нет CMRR")
		}
		switch c.Status {
		case api.CmrrStatusExcellent, api.CmrrStatusOk, api.CmrrStatusFail:
		default:
			invalid("cmrr.status", "ожидается excellent, ok или fail")
		}
		if c.CmrrDb < 0 || c.CmrrDb > 200 {
			invalid("cmrr.cmrr_db", "от 0 до 200")
		}
	}

	if f := r.FreqResponse; f != nil {
		switch f.Status {
		case api.FreqResponseStatusExcellent, api.FreqResponseStatusOk, api.FreqResponseStatusFail:
		default:
			invalid("freq_response.status", "ожидается excellent, ok или fail")
		}
		if points := len(freqTables[pv]); len(f.V) != points {
			invalid("freq_response.v", "ожидается точек: "+strconv.Itoa(points))
		}
		for _, v := range f.V {
			if v < -100 || v > 100 {
				invalid("freq_response.v", "значения от -100 до 100")
				break
			}
		}
	}
	return fields
}
