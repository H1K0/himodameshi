package server

import (
	"net/http"
	"net/url"
	"strings"
	"testing"
	"time"

	"github.com/google/uuid"
)

func cablePath(id uuid.UUID, suffix ...string) string {
	return "/api/v1/cables/" + id.String() + strings.Join(suffix, "")
}

type cableAttrs struct {
	name, cableType, color string
	note                   *string
	assignee               *uuid.UUID
	archived               bool
}

// addCable создаёт кабель в БД: маршрут создания относится к синхронизации.
func (e *testEnv) addCable(teamID, createdBy uuid.UUID, attrs cableAttrs) uuid.UUID {
	e.t.Helper()
	if attrs.name == "" {
		attrs.name = "XLR 5 м"
	}
	if attrs.cableType == "" {
		attrs.cableType = "xlr"
	}
	if attrs.color == "" {
		attrs.color = "639922"
	}
	id, err := uuid.NewV7()
	if err != nil {
		e.t.Fatal(err)
	}
	var archivedAt *time.Time
	if attrs.archived {
		now := time.Now()
		archivedAt = &now
	}
	e.exec(`INSERT INTO cables (id, team_id, name, cable_type, color, note, assignee_id, created_by, created_at, archived_at, change_seq)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, '2026-10-18T14:02:11+03:00', $9, 1)`,
		id, teamID, attrs.name, attrs.cableType, attrs.color, attrs.note, attrs.assignee, createdBy, archivedAt)
	return id
}

// addTest создаёт тест в БД; score == nil — Health Score не определён.
func (e *testEnv) addTest(cableID, authorID uuid.UUID, measuredAt time.Time, score *int, invalidated bool) {
	e.t.Helper()
	var invalidatedAt *time.Time
	var invalidatedBy *uuid.UUID
	var reason *string
	if invalidated {
		now, text := time.Now(), "сбой"
		invalidatedAt, invalidatedBy, reason = &now, &authorID, &text
	}
	e.exec(`INSERT INTO tests (id, cable_id, author_id, measured_at, device_id, pv, app_version, rules_version,
		health_score, health_incomplete, results, payload_hash, invalidated_at, invalidated_by, invalidation_reason, change_seq)
		VALUES ($1, $2, $3, $4, 'd', 1, '1', '1', $5, false, '{}', '\x00', $6, $7, $8, 1)`,
		uuid.New(), cableID, authorID, measuredAt, score, invalidatedAt, invalidatedBy, reason)
}

func score(n int) *int { return &n }

func text(s string) *string { return &s }

func cableUpdate(version int) map[string]any {
	return map[string]any{
		"version": version, "name": "XLR 5 м", "cable_type": "xlr", "color": "639922", "note": nil, "assignee_id": nil,
	}
}

func cableNames(t *testing.T, r response) []string {
	t.Helper()
	names := []string{}
	for _, item := range items(t, r) {
		names = append(names, item["name"].(string))
	}
	return names
}

func wantNames(t *testing.T, r response, want ...string) {
	t.Helper()
	got := cableNames(t, r)
	if strings.Join(got, ",") != strings.Join(want, ",") {
		t.Errorf("кабели = %v, ожидались %v", got, want)
	}
}

func TestCableRoutesRequireSession(t *testing.T) {
	id := uuid.New()
	routes := []struct{ method, path string }{
		{http.MethodGet, teamPath(id, "/cables")},
		{http.MethodGet, cablePath(id)},
		{http.MethodPut, cablePath(id)},
		{http.MethodDelete, cablePath(id)},
		{http.MethodPost, cablePath(id, "/archive")},
		{http.MethodPost, cablePath(id, "/unarchive")},
	}
	e := newEnv(t)
	for _, route := range routes {
		t.Run(route.method+" "+route.path, func(t *testing.T) {
			e.do(route.method, route.path, "{}").wantProblem(t, http.StatusUnauthorized, "unauthorized")
		})
	}
}

func TestGetCable(t *testing.T) {
	e := newEnv(t)
	owner, token := e.register("owner")
	teamID := e.addTeam(token)

	id := e.addCable(teamID, owner, cableAttrs{note: text("Запасной"), assignee: &owner})
	r := e.do(http.MethodGet, cablePath(id), nil, bearer(token))
	r.wantStatus(t, http.StatusOK)
	v := r.json(t)
	if v["id"] != id.String() || v["team_id"] != teamID.String() || v["name"] != "XLR 5 м" || v["cable_type"] != "xlr" ||
		v["color"] != "639922" || v["note"] != "Запасной" || v["version"] != float64(1) {
		t.Errorf("тело = %s", r.body)
	}
	if got := v["assignee"].(map[string]any); got["id"] != owner.String() || got["nickname"] != "owner" {
		t.Errorf("assignee = %v", got)
	}
	if got := v["created_by"].(map[string]any); got["id"] != owner.String() || got["nickname"] != "owner" {
		t.Errorf("created_by = %v", got)
	}
	if v["created_at"] != "2026-10-18T11:02:11Z" {
		t.Errorf("created_at = %v", v["created_at"])
	}

	// Без ответственного и тестов поля присутствуют и равны null.
	r = e.do(http.MethodGet, cablePath(e.addCable(teamID, owner, cableAttrs{})), nil, bearer(token))
	r.wantStatus(t, http.StatusOK)
	v = r.json(t)
	for _, field := range []string{"note", "assignee", "archived_at", "health_score", "last_test_at"} {
		if got, present := v[field]; !present || got != nil {
			t.Errorf("%s должен присутствовать и быть null: %s", field, r.body)
		}
	}
	if v["test_count"] != float64(0) {
		t.Errorf("test_count = %v", v["test_count"])
	}
}

func TestCableHealthAndLastTest(t *testing.T) {
	e := newEnv(t)
	owner, token := e.register("owner")
	teamID := e.addTeam(token)
	id := e.addCable(teamID, owner, cableAttrs{})
	base := time.Date(2026, 10, 19, 9, 0, 0, 0, time.UTC)

	// Health Score — у последнего действительного теста, last_test_at — у последнего вообще.
	e.addTest(id, owner, base, score(50), false)
	e.addTest(id, owner, base.Add(time.Hour), score(92), false)
	e.addTest(id, owner, base.Add(2*time.Hour), score(10), true)

	r := e.do(http.MethodGet, cablePath(id), nil, bearer(token))
	r.wantStatus(t, http.StatusOK)
	v := r.json(t)
	if v["health_score"] != float64(92) || v["test_count"] != float64(3) || v["last_test_at"] != "2026-10-19T11:00:00Z" {
		t.Errorf("тело = %s", r.body)
	}
}

func TestCableOfDeletedUser(t *testing.T) {
	e := newEnv(t)
	_, token := e.register("owner")
	gone, _ := e.register("gone")
	teamID := e.addTeam(token)
	id := e.addCable(teamID, gone, cableAttrs{})
	e.exec("UPDATE cables SET assignee_id = $1 WHERE id = $2", gone, id)
	e.exec("UPDATE users SET deleted_at = now() WHERE id = $1", gone)

	v := e.do(http.MethodGet, cablePath(id), nil, bearer(token)).json(t)
	for _, field := range []string{"created_by", "assignee"} {
		ref := v[field].(map[string]any)
		if nickname, present := ref["nickname"]; !present || nickname != nil || ref["id"] != gone.String() {
			t.Errorf("%s = %v", field, ref)
		}
	}
}

// Чужой кабель неотличим от несуществующего, кабель удалённой команды — тоже.
func TestCableAccess(t *testing.T) {
	e := newEnv(t)
	owner, token := e.register("owner")
	_, stranger := e.register("stranger")
	teamID := e.addTeam(token)
	id := e.addCable(teamID, owner, cableAttrs{})

	check := func(t *testing.T, cableID uuid.UUID, tok string) {
		t.Helper()
		e.do(http.MethodGet, cablePath(cableID), nil, bearer(tok)).wantProblem(t, http.StatusNotFound, "not_found")
		e.do(http.MethodPut, cablePath(cableID), cableUpdate(1), bearer(tok)).wantProblem(t, http.StatusNotFound, "not_found")
		e.do(http.MethodDelete, cablePath(cableID), nil, bearer(tok)).wantProblem(t, http.StatusNotFound, "not_found")
		e.do(http.MethodPost, cablePath(cableID, "/archive"), nil, bearer(tok)).wantProblem(t, http.StatusNotFound, "not_found")
		e.do(http.MethodPost, cablePath(cableID, "/unarchive"), nil, bearer(tok)).wantProblem(t, http.StatusNotFound, "not_found")
	}
	t.Run("чужой", func(t *testing.T) { check(t, id, stranger) })
	t.Run("несуществующий", func(t *testing.T) { check(t, uuid.New(), token) })
	t.Run("удалённая команда", func(t *testing.T) {
		e.do(http.MethodDelete, teamPath(teamID), nil, bearer(token)).wantStatus(t, http.StatusNoContent)
		check(t, id, token)
	})
	if n := e.count("SELECT count(*) FROM cables WHERE id = $1 AND version = 1 AND archived_at IS NULL", id); n != 1 {
		t.Error("кабель изменён")
	}

	e.do(http.MethodGet, "/api/v1/cables/not-a-uuid", nil, bearer(token)).
		wantProblem(t, http.StatusBadRequest, "validation_error")
}

func TestListCablesAccess(t *testing.T) {
	e := newEnv(t)
	_, token := e.register("owner")
	_, stranger := e.register("stranger")
	teamID := e.addTeam(token)

	e.do(http.MethodGet, teamPath(teamID, "/cables"), nil, bearer(stranger)).wantProblem(t, http.StatusForbidden, "no_team_access")
	e.do(http.MethodGet, teamPath(uuid.New(), "/cables"), nil, bearer(token)).wantProblem(t, http.StatusForbidden, "no_team_access")

	r := e.do(http.MethodGet, teamPath(teamID, "/cables"), nil, bearer(token))
	if got := items(t, r); len(got) != 0 {
		t.Errorf("items = %v", got)
	}
	if total := r.json(t)["total"]; total != float64(0) {
		t.Errorf("total = %v", total)
	}

	e.do(http.MethodDelete, teamPath(teamID), nil, bearer(token)).wantStatus(t, http.StatusNoContent)
	e.do(http.MethodGet, teamPath(teamID, "/cables"), nil, bearer(token)).wantProblem(t, http.StatusForbidden, "no_team_access")
}

func TestListCablesFilters(t *testing.T) {
	e := newEnv(t)
	owner, token := e.register("owner")
	member, _ := e.register("member")
	teamID := e.addTeam(token)
	e.addMember(teamID, member)
	base := time.Date(2026, 10, 19, 9, 0, 0, 0, time.UTC)

	green := e.addCable(teamID, owner, cableAttrs{name: "Зелёный XLR", cableType: "xlr", color: "00ff00", assignee: &owner})
	yellow := e.addCable(teamID, owner, cableAttrs{name: "yellow jack", cableType: "jack_ts", color: "ffff00", assignee: &member})
	red := e.addCable(teamID, owner, cableAttrs{name: "red jack", cableType: "jack_trs", color: "ff0000"})
	e.addCable(teamID, owner, cableAttrs{name: "none"})
	e.addCable(teamID, owner, cableAttrs{name: "архивный", archived: true})
	e.addTest(green, owner, base, score(80), false)
	e.addTest(yellow, owner, base, score(79), false)
	e.addTest(red, owner, base, score(39), false)
	// Недействительный тест не считается: у кабеля остаётся Health Score предыдущего.
	e.addTest(red, owner, base.Add(time.Hour), score(100), true)

	// Кабель другой команды в выдачу не попадает.
	otherOwner, otherToken := e.register("other")
	e.addCable(e.addTeam(otherToken), otherOwner, cableAttrs{name: "чужой"})

	tests := []struct {
		name  string
		query url.Values
		want  []string
	}{
		{"поиск без учёта регистра", url.Values{"q": {"JACK"}}, []string{"red jack", "yellow jack"}},
		{"поиск кириллицей", url.Values{"q": {"зелёный"}}, []string{"Зелёный XLR"}},
		{"поиск со спецсимволом", url.Values{"q": {"%"}}, []string{}},
		{"тип", url.Values{"cable_type": {"jack_ts"}}, []string{"yellow jack"}},
		{"цвет", url.Values{"color": {"ff0000"}}, []string{"red jack"}},
		{"health green", url.Values{"health": {"green"}}, []string{"Зелёный XLR"}},
		{"health yellow", url.Values{"health": {"yellow"}}, []string{"yellow jack"}},
		{"health red", url.Values{"health": {"red"}}, []string{"red jack"}},
		{"health none", url.Values{"health": {"none"}}, []string{"none"}},
		{"ответственный", url.Values{"assignee": {member.String()}}, []string{"yellow jack"}},
		{"без ответственного", url.Values{"assignee": {"none"}, "cable_type": {"jack_trs"}}, []string{"red jack"}},
		{"архив", url.Values{"archived": {"true"}}, []string{"архивный"}},
		{"не в архиве", url.Values{"archived": {"false"}, "color": {"ffff00"}}, []string{"yellow jack"}},
		{"фильтры вместе", url.Values{"q": {"jack"}, "health": {"red"}}, []string{"red jack"}},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			tt.query.Set("sort", "name")
			tt.query.Set("order", "asc")
			r := e.do(http.MethodGet, teamPath(teamID, "/cables?"+tt.query.Encode()), nil, bearer(token))
			wantNames(t, r, tt.want...)
			if total := r.json(t)["total"]; total != float64(len(tt.want)) {
				t.Errorf("total = %v, ожидалось %d", total, len(tt.want))
			}
		})
	}
}

func TestListCablesSortAndPages(t *testing.T) {
	e := newEnv(t)
	owner, token := e.register("owner")
	teamID := e.addTeam(token)
	base := time.Date(2026, 10, 19, 9, 0, 0, 0, time.UTC)

	early := e.addCable(teamID, owner, cableAttrs{name: "b ранний"})
	late := e.addCable(teamID, owner, cableAttrs{name: "A поздний"})
	e.addCable(teamID, owner, cableAttrs{name: "c без тестов"})
	e.addTest(early, owner, base, score(90), false)
	e.addTest(late, owner, base.Add(time.Hour), score(20), false)

	list := func(query string) response {
		return e.do(http.MethodGet, teamPath(teamID, "/cables"+query), nil, bearer(token))
	}
	// По умолчанию — сначала с самым свежим тестом; без значения — последними в обоих направлениях.
	wantNames(t, list(""), "A поздний", "b ранний", "c без тестов")
	wantNames(t, list("?sort=last_test_at&order=asc"), "b ранний", "A поздний", "c без тестов")
	wantNames(t, list("?sort=health_score"), "b ранний", "A поздний", "c без тестов")
	wantNames(t, list("?sort=health_score&order=asc"), "A поздний", "b ранний", "c без тестов")
	wantNames(t, list("?sort=name&order=asc"), "A поздний", "b ранний", "c без тестов")
	wantNames(t, list("?sort=name&order=desc"), "c без тестов", "b ранний", "A поздний")

	r := list("?sort=name&order=asc&limit=1&offset=1")
	wantNames(t, r, "b ранний")
	if total := r.json(t)["total"]; total != float64(3) {
		t.Errorf("total = %v", total)
	}
	// За пределами страниц список пуст, а total прежний.
	r = list("?offset=10")
	wantNames(t, r)
	if total := r.json(t)["total"]; total != float64(3) {
		t.Errorf("total = %v", total)
	}
}

func TestListCablesValidation(t *testing.T) {
	e := newEnv(t)
	_, token := e.register("owner")
	teamID := e.addTeam(token)

	tests := []struct{ name, query, field string }{
		{"длинный поиск", "q=" + strings.Repeat("я", cableSearchMaxLen+1), "q"},
		{"нулевой байт в поиске", "q=a%00b", "q"},
		{"неизвестный тип", "cable_type=rca", "cable_type"},
		{"цвет в верхнем регистре", "color=FF0000", "color"},
		{"неизвестный health", "health=blue", "health"},
		{"ответственный не UUID", "assignee=vlad", "assignee"},
		{"неизвестная сортировка", "sort=color", "sort"},
		{"неизвестный порядок", "order=up", "order"},
		{"limit 0", "limit=0", "limit"},
		{"limit больше 100", "limit=101", "limit"},
		{"отрицательный offset", "offset=-1", "offset"},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			r := e.do(http.MethodGet, teamPath(teamID, "/cables?"+tt.query), nil, bearer(token))
			r.wantProblem(t, http.StatusBadRequest, "validation_error")
			if errs := r.json(t)["errors"].([]any); errs[0].(map[string]any)["field"] != tt.field {
				t.Errorf("errors = %v, ожидалось поле %q", errs, tt.field)
			}
		})
	}
	e.do(http.MethodGet, teamPath(teamID, "/cables?limit=x"), nil, bearer(token)).
		wantProblem(t, http.StatusBadRequest, "validation_error")
	e.do(http.MethodGet, teamPath(teamID, "/cables?archived=maybe"), nil, bearer(token)).
		wantProblem(t, http.StatusBadRequest, "validation_error")
}

func TestUpdateCable(t *testing.T) {
	e := newEnv(t)
	owner, token := e.register("owner")
	member, memberToken := e.register("member")
	teamID := e.addTeam(token)
	e.addMember(teamID, member)
	e.exec("UPDATE teams SET change_seq = 5 WHERE id = $1", teamID)
	id := e.addCable(teamID, owner, cableAttrs{note: text("старая")})

	// Изменять может любой участник.
	r := e.do(http.MethodPut, cablePath(id), map[string]any{
		"version": 1, "name": "Новое имя", "cable_type": "jack_ts", "color": "abcdef", "note": nil, "assignee_id": member,
	}, bearer(memberToken))
	r.wantStatus(t, http.StatusOK)
	v := r.json(t)
	if v["name"] != "Новое имя" || v["cable_type"] != "jack_ts" || v["color"] != "abcdef" || v["note"] != nil || v["version"] != float64(2) {
		t.Errorf("тело = %s", r.body)
	}
	if got := v["assignee"].(map[string]any); got["id"] != member.String() || got["nickname"] != "member" {
		t.Errorf("assignee = %v", got)
	}

	if n := e.count("SELECT count(*) FROM cables WHERE id = $1 AND change_seq = 6 AND updated_at > created_at", id); n != 1 {
		t.Error("кабель не получил номер изменения")
	}
	if n := e.count("SELECT count(*) FROM teams WHERE id = $1 AND change_seq = 6", teamID); n != 1 {
		t.Error("счётчик команды не увеличен")
	}
	if n := e.count(`SELECT count(*) FROM audit_events WHERE team_id = $1 AND cable_id = $2 AND actor_id = $3 AND event = 'cable.updated'
		AND details #>> '{name,from}' = 'XLR 5 м' AND details #>> '{name,to}' = 'Новое имя'
		AND details #>> '{cable_type,to}' = 'jack_ts' AND details #>> '{color,to}' = 'abcdef'
		AND details #>> '{note,from}' = 'старая' AND details #> '{note,to}' = 'null'
		AND NOT details ? 'assignee_id'`, teamID, id, member); n != 1 {
		t.Error("нет записи cable.updated с «было / стало»")
	}
	if n := e.count(`SELECT count(*) FROM audit_events WHERE cable_id = $1 AND event = 'cable.assignee_changed' AND subject_user_id = $2
		AND details ->> 'to' = $3 AND details -> 'from' = 'null'`, id, member, member.String()); n != 1 {
		t.Error("нет записи cable.assignee_changed")
	}
}

func TestUpdateCableAssigneeOnly(t *testing.T) {
	e := newEnv(t)
	owner, token := e.register("owner")
	teamID := e.addTeam(token)
	id := e.addCable(teamID, owner, cableAttrs{assignee: &owner})

	// Снятие ответственного: в журнале тот, кого сняли, и только событие об ответственном.
	r := e.do(http.MethodPut, cablePath(id), cableUpdate(1), bearer(token))
	r.wantStatus(t, http.StatusOK)
	if v := r.json(t); v["assignee"] != nil || v["version"] != float64(2) {
		t.Errorf("тело = %s", r.body)
	}
	if n := e.count(`SELECT count(*) FROM audit_events WHERE cable_id = $1 AND event = 'cable.assignee_changed' AND subject_user_id = $2
		AND details ->> 'from' = $3 AND details -> 'to' = 'null'`, id, owner, owner.String()); n != 1 {
		t.Error("нет записи cable.assignee_changed")
	}
	if n := e.count("SELECT count(*) FROM audit_events WHERE cable_id = $1 AND event = 'cable.updated'", id); n != 0 {
		t.Error("лишняя запись cable.updated")
	}
}

func TestUpdateCableWithoutChanges(t *testing.T) {
	e := newEnv(t)
	owner, token := e.register("owner")
	teamID := e.addTeam(token)
	id := e.addCable(teamID, owner, cableAttrs{})

	r := e.do(http.MethodPut, cablePath(id), cableUpdate(1), bearer(token))
	r.wantStatus(t, http.StatusOK)
	if got := r.json(t)["version"]; got != float64(1) {
		t.Errorf("version = %v", got)
	}
	if n := e.count("SELECT count(*) FROM teams WHERE id = $1 AND change_seq = 0", teamID); n != 1 {
		t.Error("счётчик команды изменён")
	}
	if n := e.count("SELECT count(*) FROM audit_events WHERE cable_id = $1", id); n != 0 {
		t.Errorf("записей журнала: %d", n)
	}
}

func TestUpdateCableVersionConflict(t *testing.T) {
	e := newEnv(t)
	owner, token := e.register("owner")
	teamID := e.addTeam(token)
	id := e.addCable(teamID, owner, cableAttrs{})

	first := cableUpdate(1)
	first["name"] = "Первая правка"
	e.do(http.MethodPut, cablePath(id), first, bearer(token)).wantStatus(t, http.StatusOK)

	second := cableUpdate(1)
	second["name"] = "Вторая правка"
	r := e.do(http.MethodPut, cablePath(id), second, bearer(token))
	r.wantProblem(t, http.StatusConflict, "version_conflict")
	cable := r.json(t)["cable"].(map[string]any)
	if cable["id"] != id.String() || cable["name"] != "Первая правка" || cable["version"] != float64(2) {
		t.Errorf("cable = %v", cable)
	}

	// Правка от актуальной версии проходит.
	second["version"] = 2
	e.do(http.MethodPut, cablePath(id), second, bearer(token)).wantStatus(t, http.StatusOK)
}

func TestUpdateCableArchived(t *testing.T) {
	e := newEnv(t)
	owner, token := e.register("owner")
	teamID := e.addTeam(token)
	id := e.addCable(teamID, owner, cableAttrs{archived: true})

	r := e.do(http.MethodPut, cablePath(id), cableUpdate(1), bearer(token))
	r.wantProblem(t, http.StatusConflict, "cable_archived")
	if _, present := r.json(t)["cable"]; present {
		t.Errorf("кабель в ответе: %s", r.body)
	}
	// Архив важнее расхождения версий: разрешить такой конфликт правкой всё равно нельзя.
	e.do(http.MethodPut, cablePath(id), cableUpdate(7), bearer(token)).wantProblem(t, http.StatusConflict, "cable_archived")
}

func TestUpdateCableTypeLocked(t *testing.T) {
	e := newEnv(t)
	owner, token := e.register("owner")
	teamID := e.addTeam(token)
	id := e.addCable(teamID, owner, cableAttrs{})
	e.addTest(id, owner, time.Now(), nil, true)

	body := cableUpdate(1)
	body["cable_type"] = "jack_ts"
	// Недействительный тест — тоже тест.
	e.do(http.MethodPut, cablePath(id), body, bearer(token)).wantProblem(t, http.StatusConflict, "cable_type_locked")

	// Остальные атрибуты менять можно.
	body = cableUpdate(1)
	body["name"] = "Другое имя"
	e.do(http.MethodPut, cablePath(id), body, bearer(token)).wantStatus(t, http.StatusOK)
}

func TestUpdateCableAssigneeNotMember(t *testing.T) {
	e := newEnv(t)
	owner, token := e.register("owner")
	stranger, _ := e.register("stranger")
	teamID := e.addTeam(token)
	id := e.addCable(teamID, owner, cableAttrs{})

	for _, assignee := range []uuid.UUID{stranger, uuid.New()} {
		body := cableUpdate(1)
		body["assignee_id"] = assignee
		e.do(http.MethodPut, cablePath(id), body, bearer(token)).wantProblem(t, http.StatusConflict, "not_a_member")
	}
}

func TestUpdateCableValidation(t *testing.T) {
	e := newEnv(t)
	owner, token := e.register("owner")
	teamID := e.addTeam(token)
	id := e.addCable(teamID, owner, cableAttrs{})

	with := func(field string, value any) map[string]any {
		body := cableUpdate(1)
		body[field] = value
		return body
	}
	tests := []struct {
		name  string
		body  any
		field string
	}{
		{"нулевая версия", with("version", 0), "version"},
		{"пустое имя", with("name", ""), "name"},
		{"имя из пробелов", with("name", "   "), "name"},
		{"длинное имя", with("name", strings.Repeat("я", cableNameMaxLen+1)), "name"},
		{"нулевой байт в имени", with("name", "a\x00b"), "name"},
		{"неизвестный тип", with("cable_type", "rca"), "cable_type"},
		{"цвет с решёткой", with("color", "#639922"), "color"},
		{"цвет в верхнем регистре", with("color", "ABCDEF"), "color"},
		{"длинная заметка", with("note", strings.Repeat("я", cableNoteMaxLen+1)), "note"},
		{"нулевой байт в заметке", with("note", "a\x00b"), "note"},
		{"ответственный не UUID", with("assignee_id", "vlad"), "body"},
		{"битый JSON", "{", "body"},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			r := e.do(http.MethodPut, cablePath(id), tt.body, bearer(token))
			r.wantProblem(t, http.StatusBadRequest, "validation_error")
			if errs := r.json(t)["errors"].([]any); errs[0].(map[string]any)["field"] != tt.field {
				t.Errorf("errors = %v, ожидалось поле %q", errs, tt.field)
			}
		})
	}

	// Граничные значения допустимы.
	body := with("name", strings.Repeat("я", cableNameMaxLen))
	body["note"] = strings.Repeat("я", cableNoteMaxLen)
	e.do(http.MethodPut, cablePath(id), body, bearer(token)).wantStatus(t, http.StatusOK)
}

func TestArchiveCable(t *testing.T) {
	e := newEnv(t)
	owner, token := e.register("owner")
	member, memberToken := e.register("member")
	teamID := e.addTeam(token)
	e.addMember(teamID, member)
	id := e.addCable(teamID, owner, cableAttrs{})
	list := func(query string) []string {
		return cableNames(t, e.do(http.MethodGet, teamPath(teamID, "/cables"+query), nil, bearer(token)))
	}

	// Архивировать может любой участник.
	r := e.do(http.MethodPost, cablePath(id, "/archive"), nil, bearer(memberToken))
	r.wantStatus(t, http.StatusOK)
	v := r.json(t)
	archivedAt, _ := v["archived_at"].(string)
	if !strings.HasSuffix(archivedAt, "Z") || v["version"] != float64(2) {
		t.Errorf("тело = %s", r.body)
	}
	if len(list("")) != 0 || len(list("?archived=true")) != 1 {
		t.Error("кабель не перешёл в архивный список")
	}
	if n := e.count("SELECT count(*) FROM teams WHERE id = $1 AND change_seq = 1", teamID); n != 1 {
		t.Error("счётчик команды не увеличен")
	}
	if n := e.count(`SELECT count(*) FROM audit_events WHERE cable_id = $1 AND actor_id = $2 AND event = 'cable.archived'
		AND details ->> 'name' = 'XLR 5 м'`, id, member); n != 1 {
		t.Error("нет записи cable.archived")
	}

	// Повтор отвечает состоянием и ничего не меняет.
	r = e.do(http.MethodPost, cablePath(id, "/archive"), nil, bearer(token))
	r.wantStatus(t, http.StatusOK)
	if v := r.json(t); v["archived_at"] != archivedAt || v["version"] != float64(2) {
		t.Errorf("тело = %s", r.body)
	}
	if n := e.count("SELECT count(*) FROM audit_events WHERE cable_id = $1", id); n != 1 {
		t.Errorf("записей журнала: %d", n)
	}

	r = e.do(http.MethodPost, cablePath(id, "/unarchive"), nil, bearer(memberToken))
	r.wantStatus(t, http.StatusOK)
	if v := r.json(t); v["archived_at"] != nil || v["version"] != float64(3) {
		t.Errorf("тело = %s", r.body)
	}
	if len(list("")) != 1 {
		t.Error("кабель не вернулся в основной список")
	}
	if n := e.count("SELECT count(*) FROM audit_events WHERE cable_id = $1 AND actor_id = $2 AND event = 'cable.unarchived'", id, member); n != 1 {
		t.Error("нет записи cable.unarchived")
	}

	// Повтор возврата тоже ничего не меняет, а кабель снова принимает правки.
	r = e.do(http.MethodPost, cablePath(id, "/unarchive"), nil, bearer(token))
	r.wantStatus(t, http.StatusOK)
	if got := r.json(t)["version"]; got != float64(3) {
		t.Errorf("version = %v", got)
	}
	e.do(http.MethodPut, cablePath(id), cableUpdate(3), bearer(token)).wantStatus(t, http.StatusOK)
}

func TestDeleteCable(t *testing.T) {
	e := newEnv(t)
	owner, token := e.register("owner")
	member, memberToken := e.register("member")
	teamID := e.addTeam(token)
	e.addMember(teamID, member)
	id := e.addCable(teamID, owner, cableAttrs{archived: true})
	e.addTest(id, owner, time.Now(), score(90), false)
	e.addTest(id, owner, time.Now(), score(80), false)

	e.do(http.MethodDelete, cablePath(id), nil, bearer(memberToken)).wantProblem(t, http.StatusForbidden, "owner_only")
	e.do(http.MethodGet, cablePath(id), nil, bearer(memberToken)).wantStatus(t, http.StatusOK)

	e.do(http.MethodDelete, cablePath(id), nil, bearer(token)).wantStatus(t, http.StatusNoContent)
	e.do(http.MethodGet, cablePath(id), nil, bearer(token)).wantProblem(t, http.StatusNotFound, "not_found")
	e.do(http.MethodDelete, cablePath(id), nil, bearer(token)).wantProblem(t, http.StatusNotFound, "not_found")

	if n := e.count("SELECT count(*) FROM tests WHERE cable_id = $1", id); n != 0 {
		t.Errorf("осталось тестов: %d", n)
	}
	if n := e.count(`SELECT count(*) FROM audit_events WHERE team_id = $1 AND cable_id = $2 AND actor_id = $3 AND event = 'cable.deleted'
		AND details ->> 'name' = 'XLR 5 м' AND details ->> 'cable_type' = 'xlr' AND details ->> 'test_count' = '2'`, teamID, id, owner); n != 1 {
		t.Error("нет записи cable.deleted")
	}
}

func TestCableRoutesCheckOrigin(t *testing.T) {
	e := newEnv(t)
	owner, _ := e.register("owner")
	web := e.webCookie("owner")
	id := e.addCable(e.personalTeam(owner), owner, cableAttrs{})

	e.do(http.MethodGet, cablePath(id), nil, cookie(web)).wantStatus(t, http.StatusOK)
	e.do(http.MethodPost, cablePath(id, "/archive"), nil, cookie(web)).wantProblem(t, http.StatusForbidden, "origin_mismatch")
	e.do(http.MethodPost, cablePath(id, "/archive"), nil, cookie(web), header("Origin", testPublicURL)).wantStatus(t, http.StatusOK)
}
