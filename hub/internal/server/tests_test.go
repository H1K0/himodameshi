package server

import (
	"encoding/json"
	"net/http"
	"strings"
	"testing"
	"time"

	"github.com/google/uuid"
)

const testResultsJSON = `{
	"continuity": {"status": "ok", "future": 1, "conductors": {"pin1": {"r": 0.91, "s": "ok", "extra": "x"}}},
	"cmrr": {"status": "excellent", "cmrr_db": 72.4},
	"freq_response": {"status": "ok", "v": [0.1, -3.8]}
}`

var testT0 = time.Date(2026, 10, 19, 9, 0, 0, 0, time.UTC)

func testPath(id uuid.UUID, suffix ...string) string {
	return "/api/v1/tests/" + id.String() + strings.Join(suffix, "")
}

// addFullTest создаёт тест с результатами; время измерения — testT0 плюс minutes минут.
func (e *testEnv) addFullTest(cableID, authorID uuid.UUID, minutes int) uuid.UUID {
	e.t.Helper()
	id, err := uuid.NewV7()
	if err != nil {
		e.t.Fatal(err)
	}
	e.exec(`INSERT INTO tests (id, cable_id, author_id, measured_at, device_id, pv, app_version, rules_version,
		health_score, health_incomplete, results, payload_hash, change_seq)
		VALUES ($1, $2, $3, $4, 'A4:CF:12:8B:3E:01', 1, '0.7.0', '1', 92, false, $5, '\x00', 1)`,
		id, cableID, authorID, testT0.Add(time.Duration(minutes)*time.Minute), testResultsJSON)
	return id
}

func (e *testEnv) markInvalid(testID, by uuid.UUID) {
	e.t.Helper()
	e.exec(`UPDATE tests SET invalidated_at = now(), invalidated_by = $2, invalidation_reason = 'сбой' WHERE id = $1`, testID, by)
}

func invalidate(reason string) map[string]string {
	return map[string]string{"reason": reason}
}

func wantTestIDs(t *testing.T, r response, want ...uuid.UUID) {
	t.Helper()
	got := []string{}
	for _, item := range items(t, r) {
		got = append(got, item["id"].(string))
	}
	expected := []string{}
	for _, id := range want {
		expected = append(expected, id.String())
	}
	if strings.Join(got, ",") != strings.Join(expected, ",") {
		t.Errorf("тесты = %v, ожидались %v", got, expected)
	}
}

func TestTestRoutesRequireSession(t *testing.T) {
	id := uuid.New()
	routes := []struct{ method, path string }{
		{http.MethodGet, cablePath(id, "/tests")},
		{http.MethodGet, testPath(id)},
		{http.MethodPut, testPath(id, "/invalidation")},
		{http.MethodDelete, testPath(id, "/invalidation")},
	}
	e := newEnv(t)
	for _, route := range routes {
		t.Run(route.method+" "+route.path, func(t *testing.T) {
			e.do(route.method, route.path, "{}").wantProblem(t, http.StatusUnauthorized, "unauthorized")
		})
	}
}

func TestListCableTestsOrderAndPages(t *testing.T) {
	e := newEnv(t)
	owner, token := e.register("owner")
	cable := e.addCable(e.addTeam(token), owner, cableAttrs{})
	other := e.addCable(e.addTeam(token), owner, cableAttrs{})
	e.addFullTest(other, owner, 0)

	// Порядок вставки не совпадает со временем измерения, a и b измерены одновременно.
	c := e.addFullTest(cable, owner, 10)
	a := e.addFullTest(cable, owner, 5)
	b := e.addFullTest(cable, owner, 5)
	invalid := e.addFullTest(cable, owner, 1)
	e.markInvalid(invalid, owner)

	path := cablePath(cable, "/tests")
	r := e.do(http.MethodGet, path, nil, bearer(token))
	wantTestIDs(t, r, c, b, a, invalid) // недействительный остаётся в истории
	if got := r.json(t)["total"]; got != float64(4) {
		t.Errorf("total = %v", got)
	}
	wantTestIDs(t, e.do(http.MethodGet, path+"?order=desc", nil, bearer(token)), c, b, a, invalid)
	wantTestIDs(t, e.do(http.MethodGet, path+"?order=asc", nil, bearer(token)), invalid, a, b, c)

	r = e.do(http.MethodGet, path+"?order=asc&limit=2&offset=1", nil, bearer(token))
	wantTestIDs(t, r, a, b)
	if got := r.json(t)["total"]; got != float64(4) {
		t.Errorf("total страницы = %v", got)
	}
	r = e.do(http.MethodGet, path+"?offset=10", nil, bearer(token))
	wantTestIDs(t, r)
	if got := r.json(t)["total"]; got != float64(4) {
		t.Errorf("total за концом = %v", got)
	}

	// Результаты отдаются в списке: по ним строятся графики.
	item := items(t, e.do(http.MethodGet, path+"?limit=1", nil, bearer(token)))[0]
	freq := item["results"].(map[string]any)["freq_response"].(map[string]any)
	if f, ok := freq["f"].([]any); !ok || len(f) != 30 {
		t.Errorf("freq_response = %v", freq)
	}
}

func TestListCableTestsEmpty(t *testing.T) {
	e := newEnv(t)
	owner, token := e.register("owner")
	cable := e.addCable(e.addTeam(token), owner, cableAttrs{})
	r := e.do(http.MethodGet, cablePath(cable, "/tests"), nil, bearer(token))
	wantTestIDs(t, r)
	if got := r.json(t)["total"]; got != float64(0) {
		t.Errorf("total = %v", got)
	}
}

func TestListCableTestsValidation(t *testing.T) {
	e := newEnv(t)
	owner, token := e.register("owner")
	cable := e.addCable(e.addTeam(token), owner, cableAttrs{})
	for query, field := range map[string]string{
		"order=up":  "order",
		"limit=0":   "limit",
		"limit=101": "limit",
		"offset=-1": "offset",
	} {
		t.Run(query, func(t *testing.T) {
			r := e.do(http.MethodGet, cablePath(cable, "/tests?"+query), nil, bearer(token))
			r.wantProblem(t, http.StatusBadRequest, "validation_error")
			if got := r.json(t)["errors"].([]any)[0].(map[string]any)["field"]; got != field {
				t.Errorf("поле = %v, ожидалось %q", got, field)
			}
		})
	}
	e.do(http.MethodGet, cablePath(cable, "/tests?limit=x"), nil, bearer(token)).
		wantProblem(t, http.StatusBadRequest, "validation_error")
	e.do(http.MethodGet, "/api/v1/cables/not-a-uuid/tests", nil, bearer(token)).
		wantProblem(t, http.StatusBadRequest, "validation_error")
}

func TestGetTest(t *testing.T) {
	e := newEnv(t)
	owner, token := e.register("owner")
	cable := e.addCable(e.addTeam(token), owner, cableAttrs{})
	id := e.addFullTest(cable, owner, 0)

	r := e.do(http.MethodGet, testPath(id), nil, bearer(token))
	r.wantStatus(t, http.StatusOK)
	v := r.json(t)
	if v["id"] != id.String() || v["cable_id"] != cable.String() || v["device_id"] != "A4:CF:12:8B:3E:01" ||
		v["pv"] != float64(1) || v["app_version"] != "0.7.0" || v["rules_version"] != "1" ||
		v["health_score"] != float64(92) || v["health_incomplete"] != false {
		t.Errorf("тело = %s", r.body)
	}
	if got := v["author"].(map[string]any); got["id"] != owner.String() || got["nickname"] != "owner" {
		t.Errorf("author = %v", got)
	}
	if v["measured_at"] != "2026-10-19T09:00:00Z" {
		t.Errorf("measured_at = %v", v["measured_at"])
	}
	if got, _ := v["received_at"].(string); !strings.HasSuffix(got, "Z") {
		t.Errorf("received_at не в UTC: %v", v["received_at"])
	}
	// Необязательные значения присутствуют и равны null.
	for _, field := range []string{"firmware_version", "note", "invalidation", "insight", "previous_test_id", "reference_test_id"} {
		if got, present := v[field]; !present || got != nil {
			t.Errorf("%s должно быть null: %s", field, r.body)
		}
	}
}

func TestGetTestResults(t *testing.T) {
	e := newEnv(t)
	owner, token := e.register("owner")
	cable := e.addCable(e.addTeam(token), owner, cableAttrs{})
	id := e.addFullTest(cable, owner, 0)

	results := e.do(http.MethodGet, testPath(id), nil, bearer(token)).json(t)["results"].(map[string]any)

	// Числа и незнакомые поля не искажаются.
	continuity := results["continuity"].(map[string]any)
	if continuity["status"] != "ok" || continuity["future"] != float64(1) {
		t.Errorf("continuity = %v", continuity)
	}
	pin := continuity["conductors"].(map[string]any)["pin1"].(map[string]any)
	if pin["r"] != 0.91 || pin["s"] != "ok" || pin["extra"] != "x" {
		t.Errorf("pin1 = %v", pin)
	}
	if got := results["cmrr"].(map[string]any)["cmrr_db"]; got != 72.4 {
		t.Errorf("cmrr_db = %v", got)
	}

	// Частоты добавляются по pv при выдаче и в БД не попадают.
	freq := results["freq_response"].(map[string]any)
	f := freq["f"].([]any)
	if len(f) != 30 || f[0] != float64(10) || f[16] != float64(1000) || f[29] != float64(40000) {
		t.Errorf("f = %v", f)
	}
	if got := freq["v"].([]any); got[0] != 0.1 || got[1] != -3.8 {
		t.Errorf("v = %v", got)
	}
	if n := e.count("SELECT count(*) FROM tests WHERE results->'freq_response' ? 'f'"); n != 0 {
		t.Errorf("тестов с частотами в БД: %d", n)
	}

	// Для неизвестной версии протокола частот нет; выполненных измерений столько, сколько записано.
	e.exec("UPDATE tests SET pv = 99, results = $2 WHERE id = $1", id, `{"freq_response": {"status": "ok", "v": [1]}}`)
	r := e.do(http.MethodGet, testPath(id), nil, bearer(token))
	r.wantStatus(t, http.StatusOK)
	results = r.json(t)["results"].(map[string]any)
	if _, present := results["freq_response"].(map[string]any)["f"]; present {
		t.Errorf("частоты для неизвестного pv: %s", r.body)
	}
	if _, present := results["continuity"]; present {
		t.Errorf("невыполненное измерение в ответе: %s", r.body)
	}
}

func TestGetTestDeletedUsers(t *testing.T) {
	e := newEnv(t)
	owner, token := e.register("owner")
	author, authorToken := e.register("author")
	teamID := e.addTeam(token)
	e.exec("INSERT INTO team_members (team_id, user_id, role) VALUES ($1, $2, 'member')", teamID, author)
	cable := e.addCable(teamID, owner, cableAttrs{})
	id := e.addFullTest(cable, author, 0)
	e.markInvalid(id, author)

	e.do(http.MethodDelete, "/api/v1/me", nil, bearer(authorToken)).wantStatus(t, http.StatusNoContent)

	r := e.do(http.MethodGet, testPath(id), nil, bearer(token))
	r.wantStatus(t, http.StatusOK)
	v := r.json(t)
	got := v["author"].(map[string]any)
	if nickname, present := got["nickname"]; got["id"] != author.String() || !present || nickname != nil {
		t.Errorf("author = %v", got)
	}
	got = v["invalidation"].(map[string]any)["by"].(map[string]any)
	if nickname, present := got["nickname"]; got["id"] != author.String() || !present || nickname != nil {
		t.Errorf("invalidation.by = %v", got)
	}
}

func TestGetTestInsight(t *testing.T) {
	e := newEnv(t)
	owner, token := e.register("owner")
	cable := e.addCable(e.addTeam(token), owner, cableAttrs{})
	id := e.addFullTest(cable, owner, 0)
	insight := uuid.New()
	e.exec(`INSERT INTO insights (id, cache_key, prompt_version, model, body, created_at)
		VALUES ($1, '\x01', '1', 'glm-4.7-flash', 'Всё в норме', '2026-10-19T12:00:00+03:00')`, insight)
	e.exec("UPDATE tests SET insight_id = $2 WHERE id = $1", id, insight)

	r := e.do(http.MethodGet, testPath(id), nil, bearer(token))
	r.wantStatus(t, http.StatusOK)
	got := r.json(t)["insight"].(map[string]any)
	if got["id"] != insight.String() || got["body"] != "Всё в норме" || got["model"] != "glm-4.7-flash" ||
		got["created_at"] != "2026-10-19T09:00:00Z" {
		t.Errorf("insight = %v", got)
	}
}

func TestGetTestComparison(t *testing.T) {
	e := newEnv(t)
	owner, token := e.register("owner")
	teamID := e.addTeam(token)
	cable := e.addCable(teamID, owner, cableAttrs{})

	// Тесты другого кабеля в сравнении не участвуют.
	foreign := e.addFullTest(e.addCable(teamID, owner, cableAttrs{}), owner, -100)

	invalidFirst := e.addFullTest(cable, owner, 0)
	e.markInvalid(invalidFirst, owner)
	reference := e.addFullTest(cable, owner, 10)
	second := e.addFullTest(cable, owner, 20)
	invalidMiddle := e.addFullTest(cable, owner, 30)
	e.markInvalid(invalidMiddle, owner)
	last := e.addFullTest(cable, owner, 40)
	sameTimeA := e.addFullTest(cable, owner, 50)
	sameTimeB := e.addFullTest(cable, owner, 50)

	tests := []struct {
		name                string
		id                  uuid.UUID
		previous, reference *uuid.UUID
	}{
		{"эталонный сравнивать не с чем", reference, nil, nil},
		{"предыдущий и эталонный совпадают", second, &reference, &reference},
		{"недействительный пропускается", last, &second, &reference},
		{"при равном времени порядок по ID", sameTimeB, &sameTimeA, &reference},
		{"первый при равном времени", sameTimeA, &last, &reference},
		{"недействительный до всех действительных", invalidFirst, nil, &reference},
		{"недействительный сам получает ID", invalidMiddle, &second, &reference},
		{"единственный тест кабеля", foreign, nil, nil},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			r := e.do(http.MethodGet, testPath(tt.id), nil, bearer(token))
			r.wantStatus(t, http.StatusOK)
			v := r.json(t)
			wantID := func(field string, want *uuid.UUID) {
				t.Helper()
				got, present := v[field]
				if !present {
					t.Errorf("нет поля %s", field)
				}
				if want == nil && got != nil || want != nil && got != want.String() {
					t.Errorf("%s = %v, ожидался %v", field, got, want)
				}
			}
			wantID("previous_test_id", tt.previous)
			wantID("reference_test_id", tt.reference)
		})
	}

	// Нет действительных тестов — сравнивать не с чем.
	alone := e.addFullTest(e.addCable(teamID, owner, cableAttrs{}), owner, 0)
	e.markInvalid(alone, owner)
	v := e.do(http.MethodGet, testPath(alone), nil, bearer(token)).json(t)
	if v["previous_test_id"] != nil || v["reference_test_id"] != nil {
		t.Errorf("сравнение для единственного недействительного: %v", v)
	}
}

func TestInvalidateTest(t *testing.T) {
	e := newEnv(t)
	owner, token := e.register("owner")
	member, memberToken := e.register("member")
	teamID := e.addTeam(token)
	e.exec("INSERT INTO team_members (team_id, user_id, role) VALUES ($1, $2, 'member')", teamID, member)
	cable := e.addCable(teamID, owner, cableAttrs{})
	id := e.addFullTest(cable, owner, 0)
	e.exec("UPDATE teams SET change_seq = 10 WHERE id = $1", teamID)

	// Пометить может любой участник.
	r := e.do(http.MethodPut, testPath(id, "/invalidation"), invalidate("Перепутан кабель"), bearer(memberToken))
	r.wantStatus(t, http.StatusOK)
	v := r.json(t)
	if v["id"] != id.String() {
		t.Errorf("тело = %s", r.body)
	}
	if _, present := v["previous_test_id"]; present {
		t.Errorf("в ответе лишние поля TestDetail: %s", r.body)
	}
	mark := v["invalidation"].(map[string]any)
	by := mark["by"].(map[string]any)
	if mark["reason"] != "Перепутан кабель" || by["id"] != member.String() || by["nickname"] != "member" {
		t.Errorf("invalidation = %v", mark)
	}
	if at, _ := mark["at"].(string); !strings.HasSuffix(at, "Z") {
		t.Errorf("at не в UTC: %v", mark["at"])
	}

	// Изменение получает номер команды; кабель не меняется, журнал пополняется.
	if n := e.count("SELECT count(*) FROM tests WHERE id = $1 AND change_seq = 11", id); n != 1 {
		t.Error("change_seq теста не обновлён")
	}
	if n := e.count("SELECT count(*) FROM teams WHERE id = $1 AND change_seq = 11", teamID); n != 1 {
		t.Error("счётчик команды не увеличен")
	}
	if n := e.count("SELECT count(*) FROM cables WHERE id = $1 AND version = 1 AND change_seq = 1", cable); n != 1 {
		t.Error("кабель изменён")
	}
	if n := e.count(`SELECT count(*) FROM audit_events WHERE team_id = $1 AND actor_id = $2 AND event = 'test.invalidated'
		AND cable_id = $3 AND test_id = $4 AND details->>'reason' = 'Перепутан кабель'`, teamID, member, cable, id); n != 1 {
		t.Errorf("записей test.invalidated: %d", n)
	}

	// Тест остаётся в истории.
	wantTestIDs(t, e.do(http.MethodGet, cablePath(cable, "/tests"), nil, bearer(token)), id)

	// Повтор с той же причиной ничего не меняет.
	e.do(http.MethodPut, testPath(id, "/invalidation"), invalidate("Перепутан кабель"), bearer(token)).wantStatus(t, http.StatusOK)
	if n := e.count("SELECT count(*) FROM tests WHERE id = $1 AND change_seq = 11 AND invalidated_by = $2", id, member); n != 1 {
		t.Error("повтор с той же причиной изменил тест")
	}
	if n := e.count("SELECT count(*) FROM audit_events WHERE event = 'test.invalidated'"); n != 1 {
		t.Errorf("записей после повтора: %d", n)
	}

	// Повтор с другой причиной заменяет её вместе с автором.
	r = e.do(http.MethodPut, testPath(id, "/invalidation"), invalidate("Сбой прибора"), bearer(token))
	r.wantStatus(t, http.StatusOK)
	mark = r.json(t)["invalidation"].(map[string]any)
	if mark["reason"] != "Сбой прибора" || mark["by"].(map[string]any)["id"] != owner.String() {
		t.Errorf("invalidation = %v", mark)
	}
	if n := e.count("SELECT count(*) FROM tests WHERE id = $1 AND change_seq = 12", id); n != 1 {
		t.Error("change_seq не обновлён при замене причины")
	}
	if n := e.count("SELECT count(*) FROM audit_events WHERE event = 'test.invalidated' AND details->>'reason' = 'Сбой прибора'"); n != 1 {
		t.Errorf("записей о замене причины: %d", n)
	}
}

func TestInvalidationAffectsHealthScore(t *testing.T) {
	e := newEnv(t)
	owner, token := e.register("owner")
	cable := e.addCable(e.addTeam(token), owner, cableAttrs{})
	e.addTest(cable, owner, testT0, score(40), false)
	id := e.addFullTest(cable, owner, 10) // Health Score 92

	health := func() any {
		return e.do(http.MethodGet, cablePath(cable), nil, bearer(token)).json(t)["health_score"]
	}
	if got := health(); got != float64(92) {
		t.Fatalf("health_score = %v", got)
	}
	e.do(http.MethodPut, testPath(id, "/invalidation"), invalidate("сбой"), bearer(token)).wantStatus(t, http.StatusOK)
	if got := health(); got != float64(40) {
		t.Errorf("health_score после пометки = %v", got)
	}
	e.do(http.MethodDelete, testPath(id, "/invalidation"), nil, bearer(token)).wantStatus(t, http.StatusOK)
	if got := health(); got != float64(92) {
		t.Errorf("health_score после снятия = %v", got)
	}
}

func TestInvalidateTestValidation(t *testing.T) {
	e := newEnv(t)
	owner, token := e.register("owner")
	id := e.addFullTest(e.addCable(e.addTeam(token), owner, cableAttrs{}), owner, 0)
	path := testPath(id, "/invalidation")

	for name, body := range map[string]any{
		"пустая":           invalidate(""),
		"из пробелов":      invalidate("  \n"),
		"длиннее 500":      invalidate(strings.Repeat("я", 501)),
		"с нулевым байтом": invalidate("a\x00b"),
		"без причины":      "{}",
	} {
		t.Run(name, func(t *testing.T) {
			r := e.do(http.MethodPut, path, body, bearer(token))
			r.wantProblem(t, http.StatusBadRequest, "validation_error")
			if got := r.json(t)["errors"].([]any)[0].(map[string]any)["field"]; got != "reason" {
				t.Errorf("поле = %v", got)
			}
		})
	}
	e.do(http.MethodPut, path, "{", bearer(token)).wantProblem(t, http.StatusBadRequest, "validation_error")
	e.do(http.MethodPut, path, `{"reason": 1}`, bearer(token)).wantProblem(t, http.StatusBadRequest, "validation_error")

	if n := e.count("SELECT count(*) FROM tests WHERE invalidated_at IS NOT NULL"); n != 0 {
		t.Error("тест помечен при ошибке проверки")
	}

	// 500 символов считаются в символах, а не байтах.
	e.do(http.MethodPut, path, invalidate(strings.Repeat("я", 500)), bearer(token)).wantStatus(t, http.StatusOK)
}

func TestRevalidateTest(t *testing.T) {
	e := newEnv(t)
	owner, token := e.register("owner")
	teamID := e.addTeam(token)
	cable := e.addCable(teamID, owner, cableAttrs{})
	id := e.addFullTest(cable, owner, 0)
	e.exec("UPDATE teams SET change_seq = 10 WHERE id = $1", teamID)
	path := testPath(id, "/invalidation")

	// Снятие несуществующей пометки ничего не меняет.
	r := e.do(http.MethodDelete, path, nil, bearer(token))
	r.wantStatus(t, http.StatusOK)
	if got, present := r.json(t)["invalidation"]; !present || got != nil {
		t.Errorf("invalidation = %v", got)
	}
	if n := e.count("SELECT count(*) FROM teams WHERE id = $1 AND change_seq = 10", teamID); n != 1 {
		t.Error("счётчик увеличен без изменения")
	}
	if n := e.count("SELECT count(*) FROM audit_events WHERE event = 'test.revalidated'"); n != 0 {
		t.Error("запись в журнале без изменения")
	}

	e.do(http.MethodPut, path, invalidate("сбой"), bearer(token)).wantStatus(t, http.StatusOK)
	r = e.do(http.MethodDelete, path, nil, bearer(token))
	r.wantStatus(t, http.StatusOK)
	if got, present := r.json(t)["invalidation"]; !present || got != nil {
		t.Errorf("invalidation после снятия = %v", got)
	}
	if n := e.count(`SELECT count(*) FROM tests WHERE id = $1 AND invalidated_at IS NULL AND invalidated_by IS NULL
		AND invalidation_reason IS NULL AND change_seq = 12`, id); n != 1 {
		t.Error("пометка не снята или change_seq не обновлён")
	}
	// В журнале — прежняя причина.
	if n := e.count(`SELECT count(*) FROM audit_events WHERE team_id = $1 AND actor_id = $2 AND event = 'test.revalidated'
		AND cable_id = $3 AND test_id = $4 AND details->>'reason' = 'сбой'`, teamID, owner, cable, id); n != 1 {
		t.Errorf("записей test.revalidated: %d", n)
	}
}

func TestInvalidationArchivedCable(t *testing.T) {
	e := newEnv(t)
	owner, token := e.register("owner")
	teamID := e.addTeam(token)
	cable := e.addCable(teamID, owner, cableAttrs{archived: true})
	marked := e.addFullTest(cable, owner, 0)
	e.markInvalid(marked, owner)
	clean := e.addFullTest(cable, owner, 1)

	e.do(http.MethodPut, testPath(clean, "/invalidation"), invalidate("сбой"), bearer(token)).
		wantProblem(t, http.StatusConflict, "cable_archived")
	e.do(http.MethodDelete, testPath(marked, "/invalidation"), nil, bearer(token)).
		wantProblem(t, http.StatusConflict, "cable_archived")
	// Повтор без изменений на архивном кабеле — тоже отказ.
	e.do(http.MethodDelete, testPath(clean, "/invalidation"), nil, bearer(token)).
		wantProblem(t, http.StatusConflict, "cable_archived")

	if n := e.count("SELECT count(*) FROM tests WHERE id = $1 AND invalidated_at IS NOT NULL", marked); n != 1 {
		t.Error("пометка снята на архивном кабеле")
	}
	if n := e.count("SELECT count(*) FROM tests WHERE id = $1 AND invalidated_at IS NULL", clean); n != 1 {
		t.Error("тест помечен на архивном кабеле")
	}
	if n := e.count("SELECT count(*) FROM teams WHERE id = $1 AND change_seq = 0", teamID); n != 1 {
		t.Error("счётчик команды увеличен")
	}

	// Чтение архивного кабеля доступно, ошибка проверки важнее конфликта.
	e.do(http.MethodGet, testPath(clean), nil, bearer(token)).wantStatus(t, http.StatusOK)
	e.do(http.MethodGet, cablePath(cable, "/tests"), nil, bearer(token)).wantStatus(t, http.StatusOK)
	e.do(http.MethodPut, testPath(clean, "/invalidation"), invalidate(""), bearer(token)).
		wantProblem(t, http.StatusBadRequest, "validation_error")
}

func TestTestAccess(t *testing.T) {
	e := newEnv(t)
	owner, token := e.register("owner")
	_, stranger := e.register("stranger")
	teamID := e.addTeam(token)
	cable := e.addCable(teamID, owner, cableAttrs{})
	id := e.addFullTest(cable, owner, 0)

	check := func(t *testing.T, tok string) {
		t.Helper()
		for _, r := range []response{
			e.do(http.MethodGet, cablePath(cable, "/tests"), nil, bearer(tok)),
			e.do(http.MethodGet, testPath(id), nil, bearer(tok)),
			e.do(http.MethodPut, testPath(id, "/invalidation"), invalidate("сбой"), bearer(tok)),
			e.do(http.MethodDelete, testPath(id, "/invalidation"), nil, bearer(tok)),
		} {
			r.wantProblem(t, http.StatusNotFound, "not_found")
		}
	}

	// Чужой тест неотличим от несуществующего.
	t.Run("чужая команда", func(t *testing.T) { check(t, stranger) })
	if n := e.count("SELECT count(*) FROM tests WHERE invalidated_at IS NOT NULL"); n != 0 {
		t.Error("чужой пользователь пометил тест")
	}

	t.Run("удалённая команда", func(t *testing.T) {
		e.exec("UPDATE teams SET deleted_at = now() WHERE id = $1", teamID)
		defer e.exec("UPDATE teams SET deleted_at = NULL WHERE id = $1", teamID)
		check(t, token)
	})

	t.Run("нет такого", func(t *testing.T) {
		missing := uuid.New()
		e.do(http.MethodGet, cablePath(missing, "/tests"), nil, bearer(token)).wantProblem(t, http.StatusNotFound, "not_found")
		e.do(http.MethodGet, testPath(missing), nil, bearer(token)).wantProblem(t, http.StatusNotFound, "not_found")
		e.do(http.MethodPut, testPath(missing, "/invalidation"), invalidate("сбой"), bearer(token)).wantProblem(t, http.StatusNotFound, "not_found")
		e.do(http.MethodDelete, testPath(missing, "/invalidation"), nil, bearer(token)).wantProblem(t, http.StatusNotFound, "not_found")
	})
}

func TestInvalidationWebOrigin(t *testing.T) {
	e := newEnv(t)
	owner, token := e.register("owner")
	id := e.addFullTest(e.addCable(e.addTeam(token), owner, cableAttrs{}), owner, 0)
	web := e.webCookie("owner")
	path := testPath(id, "/invalidation")

	e.do(http.MethodPut, path, invalidate("сбой"), cookie(web)).wantProblem(t, http.StatusForbidden, "origin_mismatch")
	e.do(http.MethodDelete, path, nil, cookie(web)).wantProblem(t, http.StatusForbidden, "origin_mismatch")
	e.do(http.MethodPut, path, invalidate("сбой"), cookie(web), header("Origin", testPublicURL)).wantStatus(t, http.StatusOK)
}

func TestTestJSONFloats(t *testing.T) {
	e := newEnv(t)
	owner, token := e.register("owner")
	id := e.addFullTest(e.addCable(e.addTeam(token), owner, cableAttrs{}), owner, 0)

	// Значения приходят ровно такими, какими записаны, а не с погрешностью float32.
	var v struct {
		Results struct {
			Cmrr struct {
				Db json.Number `json:"cmrr_db"`
			} `json:"cmrr"`
		} `json:"results"`
	}
	if err := json.Unmarshal(e.do(http.MethodGet, testPath(id), nil, bearer(token)).body, &v); err != nil {
		t.Fatal(err)
	}
	if v.Results.Cmrr.Db != "72.4" {
		t.Errorf("cmrr_db = %s", v.Results.Cmrr.Db)
	}
}
