package server

import (
	"net/http"
	"strings"
	"testing"
	"time"

	"github.com/google/uuid"
)

const (
	pushPath = "/api/v1/sync/push"
	pullPath = "/api/v1/sync/pull"
)

func newID(t *testing.T) uuid.UUID {
	t.Helper()
	id, err := uuid.NewV7()
	if err != nil {
		t.Fatal(err)
	}
	return id
}

func newCable(id, teamID uuid.UUID, cableType string) map[string]any {
	return map[string]any{
		"id": id, "team_id": teamID, "name": "XLR 5 м", "cable_type": cableType,
		"color": "639922", "note": nil, "created_at": "2026-10-18T17:02:11+03:00",
	}
}

func cableUpdateItem(id uuid.UUID, version int, name string) map[string]any {
	update := cableUpdate(version)
	update["id"] = id
	update["name"] = name
	return update
}

// newTest — тест кабеля xlr со всеми измерениями; minute задаёт время измерения.
func newTest(id, cableID uuid.UUID, minute int) map[string]any {
	v := make([]float64, 30)
	v[29] = -3.8
	return map[string]any{
		"id": id, "cable_id": cableID,
		"measured_at": testT0.Add(time.Duration(minute) * time.Minute).Format("2006-01-02T15:04:05Z07:00"),
		"device_id":   "A4:CF:12:8B:3E:01", "pv": 1, "app_version": "0.7.0", "rules_version": "1",
		"firmware_version": nil, "health_score": 92, "health_incomplete": false, "note": nil,
		"results": map[string]any{
			"continuity": map[string]any{"status": "ok", "future": 1, "conductors": map[string]any{
				"pin1": map[string]any{"r": 0.91, "s": "ok"},
				"pin2": map[string]any{"r": 1.02, "s": "ok", "extra": "x"},
				"pin3": map[string]any{"r": 0.95, "s": "ok"},
			}},
			"cmrr":          map[string]any{"status": "excellent", "cmrr_db": 72.4},
			"freq_response": map[string]any{"status": "ok", "v": v},
		},
	}
}

func pushBody(cables, updates, tests []map[string]any) map[string]any {
	none := []map[string]any{}
	if cables == nil {
		cables = none
	}
	if updates == nil {
		updates = none
	}
	if tests == nil {
		tests = none
	}
	return map[string]any{"cables": cables, "cable_updates": updates, "tests": tests}
}

func pullBody(teamID uuid.UUID, cursor int, cables ...uuid.UUID) map[string]any {
	return map[string]any{"team_id": teamID, "cursor": cursor, "cables": cables}
}

// pushResults отдаёт результаты раздела ответа push в порядке объектов запроса.
func pushResults(t *testing.T, r response, section string) []map[string]any {
	t.Helper()
	r.wantStatus(t, http.StatusOK)
	raw, ok := r.json(t)[section].([]any)
	if !ok {
		t.Fatalf("%s не массив: %s", section, r.body)
	}
	results := make([]map[string]any, 0, len(raw))
	for _, item := range raw {
		results = append(results, item.(map[string]any))
	}
	return results
}

// wantItem проверяет результат объекта: code == "" — принят, иначе отклонён с этим кодом.
func wantItem(t *testing.T, item map[string]any, code string) {
	t.Helper()
	if code == "" {
		if item["status"] != "accepted" || item["error"] != nil {
			t.Errorf("объект %v не принят", item)
		}
		return
	}
	errBody, _ := item["error"].(map[string]any)
	if item["status"] != "rejected" || errBody["code"] != code {
		t.Errorf("объект %v, ожидался отказ %q", item, code)
	}
}

func (e *testEnv) changeSeq(teamID uuid.UUID) int {
	e.t.Helper()
	return e.count("SELECT change_seq FROM teams WHERE id = $1", teamID)
}

func TestSyncRoutesRequireSession(t *testing.T) {
	e := newEnv(t)
	for _, path := range []string{pushPath, pullPath} {
		t.Run(path, func(t *testing.T) {
			e.do(http.MethodPost, path, "{}").wantProblem(t, http.StatusUnauthorized, "unauthorized")
		})
	}
}

func TestSyncPushCreatesCableAndTest(t *testing.T) {
	e := newEnv(t)
	userID, token := e.register("vlad")
	teamID := e.personalTeam(userID)
	cableID, testID := newID(t), newID(t)

	test := newTest(testID, cableID, 0)
	// Частоты АЧХ присылать не нужно: сервер их не хранит и добавляет сам.
	test["results"].(map[string]any)["freq_response"].(map[string]any)["f"] = []int{1, 2}
	r := e.do(http.MethodPost, pushPath, pushBody(
		[]map[string]any{newCable(cableID, teamID, "xlr")}, nil, []map[string]any{test},
	), bearer(token))

	cables := pushResults(t, r, "cables")
	wantItem(t, cables[0], "")
	cable := cables[0]["cable"].(map[string]any)
	if cable["version"] != float64(1) || cable["created_at"] != "2026-10-18T14:02:11Z" || cable["team_id"] != teamID.String() {
		t.Errorf("cable = %v", cable)
	}
	if updates := pushResults(t, r, "cable_updates"); len(updates) != 0 {
		t.Errorf("cable_updates = %v", updates)
	}
	wantItem(t, pushResults(t, r, "tests")[0], "")

	if n := e.changeSeq(teamID); n != 2 {
		t.Errorf("change_seq команды = %d, ожидалось 2", n)
	}
	if n := e.count(`SELECT count(*) FROM audit_events WHERE event IN ('cable.created', 'test.uploaded')
		AND cable_id = $1 AND actor_id = $2`, cableID, userID); n != 2 {
		t.Errorf("событий журнала: %d", n)
	}

	got := e.do(http.MethodGet, testPath(testID), nil, bearer(token))
	got.wantStatus(t, http.StatusOK)
	body := string(got.body)
	for _, part := range []string{`"future":1`, `"extra":"x"`, `"f":[10,13,`, `"author":{"id":"` + userID.String()} {
		if !strings.Contains(body, part) {
			t.Errorf("в тесте нет %s: %s", part, body)
		}
	}
}

func TestSyncPushRepeat(t *testing.T) {
	e := newEnv(t)
	userID, token := e.register("vlad")
	teamID := e.personalTeam(userID)
	cableID, testID := newID(t), newID(t)
	batch := pushBody([]map[string]any{newCable(cableID, teamID, "xlr")}, nil, []map[string]any{newTest(testID, cableID, 0)})

	e.do(http.MethodPost, pushPath, batch, bearer(token)).wantStatus(t, http.StatusOK)
	// Кабель тем временем переименовали в вебе: повтор отдаёт актуальное состояние.
	e.do(http.MethodPut, cablePath(cableID), cableUpdateItem(cableID, 1, "XLR сцена"), bearer(token)).wantStatus(t, http.StatusOK)
	seq := e.changeSeq(teamID)

	r := e.do(http.MethodPost, pushPath, batch, bearer(token))
	cables := pushResults(t, r, "cables")
	wantItem(t, cables[0], "")
	if cable := cables[0]["cable"].(map[string]any); cable["name"] != "XLR сцена" || cable["version"] != float64(2) {
		t.Errorf("cable = %v", cable)
	}
	wantItem(t, pushResults(t, r, "tests")[0], "")
	if n := e.changeSeq(teamID); n != seq {
		t.Errorf("повтор изменил change_seq: %d → %d", seq, n)
	}
	if n := e.count("SELECT count(*) FROM tests"); n != 1 {
		t.Errorf("тестов: %d", n)
	}
}

func TestSyncPushRejections(t *testing.T) {
	e := newEnv(t)
	userID, token := e.register("vlad")
	strangerID, _ := e.register("stranger")
	teamID := e.personalTeam(userID)
	foreignTeam := e.personalTeam(strangerID)

	cableID := e.addCable(teamID, userID, cableAttrs{})
	jackTS := e.addCable(teamID, userID, cableAttrs{cableType: "jack_ts"})
	archived := e.addCable(teamID, userID, cableAttrs{archived: true})
	foreignCable := e.addCable(foreignTeam, strangerID, cableAttrs{})
	e.do(http.MethodPut, cablePath(cableID), cableUpdateItem(cableID, 1, "XLR веб"), bearer(token)).wantStatus(t, http.StatusOK)

	existingTest := newID(t)
	e.do(http.MethodPost, pushPath, pushBody(nil, nil, []map[string]any{newTest(existingTest, cableID, 0)}), bearer(token)).
		wantStatus(t, http.StatusOK)

	badName := newCable(newID(t), teamID, "xlr")
	badName["name"] = " "
	changedTest := newTest(existingTest, cableID, 5)
	cmrrOnTS := newTest(newID(t), jackTS, 0)
	shortFreq := newTest(newID(t), cableID, 0)
	shortFreq["results"].(map[string]any)["freq_response"].(map[string]any)["v"] = []float64{0, 1}
	acceptedTest := newID(t)

	r := e.do(http.MethodPost, pushPath, pushBody(
		[]map[string]any{
			newCable(foreignCable, teamID, "xlr"),  // ID занят в чужой команде
			newCable(newID(t), foreignTeam, "xlr"), // не участник команды
			badName,
		},
		[]map[string]any{
			cableUpdateItem(cableID, 1, "XLR телефон"), // устаревшая версия
			cableUpdateItem(archived, 1, "Архив"),
			cableUpdateItem(foreignCable, 1, "Чужой"),
			cableUpdateItem(newID(t), 1, "Нет такого"),
		},
		[]map[string]any{
			changedTest,
			newTest(newID(t), newID(t), 0),
			newTest(newID(t), archived, 0),
			newTest(newID(t), foreignCable, 0),
			cmrrOnTS,
			shortFreq,
			newTest(acceptedTest, cableID, 10),
		},
	), bearer(token))

	cables := pushResults(t, r, "cables")
	for i, code := range []string{"id_conflict", "no_team_access", "validation_error"} {
		wantItem(t, cables[i], code)
	}
	updates := pushResults(t, r, "cable_updates")
	for i, code := range []string{"version_conflict", "cable_archived", "no_team_access", "cable_not_found"} {
		wantItem(t, updates[i], code)
	}
	if cable, _ := updates[0]["cable"].(map[string]any); cable["name"] != "XLR веб" || cable["version"] != float64(2) {
		t.Errorf("при version_conflict нет актуального кабеля: %v", updates[0])
	}
	if _, present := updates[1]["cable"]; present {
		t.Errorf("при cable_archived передан кабель: %v", updates[1])
	}
	tests := pushResults(t, r, "tests")
	for i, code := range []string{"id_conflict", "cable_not_found", "cable_archived", "no_team_access", "validation_error", "validation_error", ""} {
		wantItem(t, tests[i], code)
	}
	if detail, _ := tests[4]["error"].(map[string]any)["detail"].(string); !strings.Contains(detail, "results.continuity.conductors") ||
		!strings.Contains(detail, "results.cmrr") {
		t.Errorf("detail = %q", detail)
	}

	// Отказы откатились, принятый тест сохранён.
	if n := e.count("SELECT count(*) FROM tests"); n != 2 {
		t.Errorf("тестов: %d", n)
	}
	if n := e.count("SELECT count(*) FROM tests WHERE id = $1", acceptedTest); n != 1 {
		t.Errorf("принятый тест не сохранён")
	}
	if n := e.count("SELECT count(*) FROM cables"); n != 4 {
		t.Errorf("кабелей: %d", n)
	}
}

func TestSyncPushValidation(t *testing.T) {
	e := newEnv(t)
	userID, token := e.register("vlad")
	teamID := e.personalTeam(userID)

	cables := make([]map[string]any, 0, 101)
	for range 101 {
		cables = append(cables, newCable(newID(t), teamID, "xlr"))
	}
	e.do(http.MethodPost, pushPath, pushBody(cables, nil, nil), bearer(token)).
		wantProblem(t, http.StatusBadRequest, "validation_error")
	e.do(http.MethodPost, pushPath, "{", bearer(token)).wantProblem(t, http.StatusBadRequest, "validation_error")
	if n := e.count("SELECT count(*) FROM cables"); n != 0 {
		t.Errorf("кабелей: %d", n)
	}
}

func TestSyncPullPages(t *testing.T) {
	e := newEnv(t)
	userID, token := e.register("vlad")
	teamID := e.personalTeam(userID)
	cableID := newID(t)

	// 150 тестов — две выгрузки: кабель и 99 тестов, затем ещё 51 тест.
	first := []map[string]any{}
	for i := range 99 {
		first = append(first, newTest(newID(t), cableID, i))
	}
	e.do(http.MethodPost, pushPath, pushBody([]map[string]any{newCable(cableID, teamID, "xlr")}, nil, first), bearer(token)).
		wantStatus(t, http.StatusOK)
	second := []map[string]any{}
	for i := range 51 {
		second = append(second, newTest(newID(t), cableID, 100+i))
	}
	e.do(http.MethodPost, pushPath, pushBody(nil, nil, second), bearer(token)).wantStatus(t, http.StatusOK)
	// Переименование — последнее изменение команды, номер 152.
	e.do(http.MethodPut, cablePath(cableID), cableUpdateItem(cableID, 1, "XLR сцена"), bearer(token)).wantStatus(t, http.StatusOK)
	missing := newID(t)

	r := e.do(http.MethodPost, pullPath, pullBody(teamID, 0, cableID, missing, cableID), bearer(token))
	r.wantStatus(t, http.StatusOK)
	page := r.json(t)
	if page["has_more"] != true || page["cursor"] != float64(101) || len(page["tests"].([]any)) != 100 {
		t.Fatalf("первая страница: has_more %v, cursor %v, тестов %d", page["has_more"], page["cursor"], len(page["tests"].([]any)))
	}
	// Кабель изменён после курсора страницы — придёт со следующей.
	if cables := page["cables"].([]any); len(cables) != 0 {
		t.Errorf("кабели первой страницы: %v", cables)
	}
	if deleted := page["deleted_cables"].([]any); len(deleted) != 1 || deleted[0] != missing.String() {
		t.Errorf("deleted_cables = %v", deleted)
	}

	r = e.do(http.MethodPost, pullPath, pullBody(teamID, 101, cableID), bearer(token))
	r.wantStatus(t, http.StatusOK)
	page = r.json(t)
	if page["has_more"] != false || page["cursor"] != float64(152) || len(page["tests"].([]any)) != 50 {
		t.Fatalf("вторая страница: has_more %v, cursor %v, тестов %d", page["has_more"], page["cursor"], len(page["tests"].([]any)))
	}
	cables := page["cables"].([]any)
	if len(cables) != 1 || cables[0].(map[string]any)["name"] != "XLR сцена" || cables[0].(map[string]any)["test_count"] != float64(150) {
		t.Errorf("cables = %v", cables)
	}
	if deleted := page["deleted_cables"].([]any); len(deleted) != 0 {
		t.Errorf("deleted_cables = %v", deleted)
	}

	// Пометка «недействительный» возвращает тест в pull, курсор после неё — без изменений.
	tests := page["tests"].([]any)
	lastTest := uuid.MustParse(tests[len(tests)-1].(map[string]any)["id"].(string))
	e.do(http.MethodPut, testPath(lastTest, "/invalidation"), invalidate("Не тот кабель"), bearer(token)).wantStatus(t, http.StatusOK)
	r = e.do(http.MethodPost, pullPath, pullBody(teamID, 152, cableID), bearer(token))
	r.wantStatus(t, http.StatusOK)
	page = r.json(t)
	tests = page["tests"].([]any)
	if len(tests) != 1 || tests[0].(map[string]any)["invalidation"] == nil || page["cursor"] != float64(153) {
		t.Errorf("после пометки: %s", r.body)
	}
	if cables := page["cables"].([]any); len(cables) != 0 {
		t.Errorf("кабель без изменений попал в pull: %v", cables)
	}
}

func TestSyncPullOnlyTeamCables(t *testing.T) {
	e := newEnv(t)
	userID, token := e.register("vlad")
	strangerID, strangerToken := e.register("stranger")
	teamID := e.personalTeam(userID)
	foreignCable := e.addCable(e.personalTeam(strangerID), strangerID, cableAttrs{})
	e.addFullTest(foreignCable, strangerID, 0)

	// Кабель чужой команды неотличим от удалённого, его тесты не отдаются.
	r := e.do(http.MethodPost, pullPath, pullBody(teamID, 0, foreignCable), bearer(token))
	r.wantStatus(t, http.StatusOK)
	page := r.json(t)
	if len(page["tests"].([]any)) != 0 || len(page["cables"].([]any)) != 0 || len(page["deleted_cables"].([]any)) != 1 {
		t.Errorf("pull чужого кабеля: %s", r.body)
	}

	e.do(http.MethodPost, pullPath, pullBody(teamID, 0, foreignCable), bearer(strangerToken)).
		wantProblem(t, http.StatusForbidden, "no_team_access")
	e.do(http.MethodPost, pullPath, pullBody(uuid.New(), 0, foreignCable), bearer(token)).
		wantProblem(t, http.StatusForbidden, "no_team_access")
}

func TestSyncPullValidation(t *testing.T) {
	e := newEnv(t)
	userID, token := e.register("vlad")
	teamID := e.personalTeam(userID)

	tests := []struct {
		name  string
		body  any
		field string
	}{
		{"отрицательный курсор", pullBody(teamID, -1, uuid.New()), "cursor"},
		{"пустой список кабелей", pullBody(teamID, 0), "cables"},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			r := e.do(http.MethodPost, pullPath, tt.body, bearer(token))
			r.wantProblem(t, http.StatusBadRequest, "validation_error")
			errs := r.json(t)["errors"].([]any)
			if errs[0].(map[string]any)["field"] != tt.field {
				t.Errorf("errors = %v, ожидалось поле %q", errs, tt.field)
			}
		})
	}
}
