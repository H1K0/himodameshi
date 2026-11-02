package server

import (
	"context"
	"encoding/json"
	"net/http"
	"strings"
	"testing"
	"time"

	"github.com/google/uuid"

	"git.hakoniwa.ru/tech/himodameshi/hub/internal/config"
)

func teamPath(id uuid.UUID, suffix ...string) string {
	return "/api/v1/teams/" + id.String() + strings.Join(suffix, "")
}

// addTeam создаёт команду через API и возвращает её ID.
func (e *testEnv) addTeam(token string) uuid.UUID {
	e.t.Helper()
	r := e.do(http.MethodPost, "/api/v1/teams", map[string]string{"name": "studio"}, bearer(token))
	r.wantStatus(e.t, http.StatusCreated)
	id, err := uuid.Parse(r.json(e.t)["id"].(string))
	if err != nil {
		e.t.Fatal(err)
	}
	return id
}

func (e *testEnv) addMember(teamID, userID uuid.UUID) {
	e.t.Helper()
	e.exec("INSERT INTO team_members (team_id, user_id, role) VALUES ($1, $2, 'member')", teamID, userID)
}

func (e *testEnv) personalTeam(userID uuid.UUID) uuid.UUID {
	e.t.Helper()
	var id uuid.UUID
	err := e.db.QueryRow(context.Background(), `SELECT t.id FROM teams t JOIN team_members m ON m.team_id = t.id
		WHERE t.is_personal AND m.user_id = $1`, userID).Scan(&id)
	if err != nil {
		e.t.Fatal(err)
	}
	return id
}

func items(t *testing.T, r response) []map[string]any {
	t.Helper()
	r.wantStatus(t, http.StatusOK)
	var v struct {
		Items []map[string]any `json:"items"`
	}
	if err := json.Unmarshal(r.body, &v); err != nil {
		t.Fatal(err)
	}
	if v.Items == nil {
		t.Fatalf("items не массив: %s", r.body)
	}
	return v.Items
}

func TestTeamRoutesRequireSession(t *testing.T) {
	id := uuid.NewString()
	routes := []struct{ method, path string }{
		{http.MethodGet, "/api/v1/teams"},
		{http.MethodPost, "/api/v1/teams"},
		{http.MethodGet, "/api/v1/teams/" + id},
		{http.MethodPatch, "/api/v1/teams/" + id},
		{http.MethodDelete, "/api/v1/teams/" + id},
		{http.MethodPost, "/api/v1/teams/" + id + "/restore"},
		{http.MethodPost, "/api/v1/teams/" + id + "/transfer-ownership"},
		{http.MethodPost, "/api/v1/teams/" + id + "/leave"},
		{http.MethodGet, "/api/v1/teams/" + id + "/members"},
		{http.MethodDelete, "/api/v1/teams/" + id + "/members/" + id},
	}
	e := newEnv(t)
	for _, route := range routes {
		t.Run(route.method+" "+route.path, func(t *testing.T) {
			e.do(route.method, route.path, "{}").wantProblem(t, http.StatusUnauthorized, "unauthorized")
		})
	}
}

func TestInvalidTeamID(t *testing.T) {
	e := newEnv(t)
	_, token := e.register("owner")
	e.do(http.MethodGet, "/api/v1/teams/not-a-uuid", nil, bearer(token)).
		wantProblem(t, http.StatusBadRequest, "validation_error")
	e.do(http.MethodGet, "/api/v1/teams?deleted=maybe", nil, bearer(token)).
		wantProblem(t, http.StatusBadRequest, "validation_error")
}

func TestCreateTeam(t *testing.T) {
	e := newEnv(t)
	userID, token := e.register("owner")

	r := e.do(http.MethodPost, "/api/v1/teams", map[string]string{"name": "Студия", "description": "Подвал"}, bearer(token))
	r.wantStatus(t, http.StatusCreated)
	v := r.json(t)
	if v["name"] != "Студия" || v["description"] != "Подвал" || v["is_personal"] != false ||
		v["role"] != "owner" || v["member_count"] != float64(1) {
		t.Errorf("тело = %s", r.body)
	}
	if deletedAt, present := v["deleted_at"]; !present || deletedAt != nil {
		t.Errorf("deleted_at должен присутствовать и быть null: %s", r.body)
	}
	if plan := v["plan"].(map[string]any); plan["key"] != "free" || plan["max_members"] != float64(5) {
		t.Errorf("plan = %v", plan)
	}
	if !strings.HasSuffix(v["created_at"].(string), "Z") {
		t.Errorf("created_at не в UTC: %v", v["created_at"])
	}
	id, err := uuid.Parse(v["id"].(string))
	if err != nil || id.Version() != 7 {
		t.Errorf("id %v не UUIDv7: %v", v["id"], err)
	}
	if n := e.count("SELECT count(*) FROM team_members WHERE team_id = $1 AND user_id = $2 AND role = 'owner'", id, userID); n != 1 {
		t.Error("создатель не стал владельцем")
	}

	// Описание необязательно.
	r = e.do(http.MethodPost, "/api/v1/teams", map[string]string{"name": "x"}, bearer(token))
	r.wantStatus(t, http.StatusCreated)
	if got := r.json(t)["description"]; got != "" {
		t.Errorf("description = %v", got)
	}
}

func TestTeamValidation(t *testing.T) {
	long := strings.Repeat("я", teamNameMaxLen)
	longDescription := strings.Repeat("я", teamDescriptionMaxLen)
	e := newEnv(t)
	_, token := e.register("owner")
	teamID := e.addTeam(token)

	tests := []struct {
		name  string
		body  any
		field string
	}{
		{"пустое название", map[string]string{"name": ""}, "name"},
		{"название из пробелов", map[string]string{"name": "   "}, "name"},
		{"длинное название", map[string]string{"name": long + "я"}, "name"},
		{"нулевой байт в названии", `{"name": "a\u0000b"}`, "name"},
		{"длинное описание", map[string]string{"name": "x", "description": longDescription + "я"}, "description"},
		{"битый JSON", "{", "body"},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			for _, r := range []response{
				e.do(http.MethodPost, "/api/v1/teams", tt.body, bearer(token)),
				e.do(http.MethodPatch, teamPath(teamID), tt.body, bearer(token)),
			} {
				r.wantProblem(t, http.StatusBadRequest, "validation_error")
				if got := r.json(t)["errors"].([]any)[0].(map[string]any)["field"]; got != tt.field {
					t.Errorf("поле = %v, ожидалось %q", got, tt.field)
				}
			}
		})
	}

	// Название длиной ровно в предел считается по символам, а не по байтам.
	e.do(http.MethodPost, "/api/v1/teams", map[string]string{"name": long, "description": longDescription}, bearer(token)).
		wantStatus(t, http.StatusCreated)
	// При создании название обязательно.
	e.do(http.MethodPost, "/api/v1/teams", map[string]string{"description": "x"}, bearer(token)).
		wantProblem(t, http.StatusBadRequest, "validation_error")
}

func TestListTeams(t *testing.T) {
	e := newEnv(t)
	ownerID, owner := e.register("owner")
	memberID, member := e.register("member")
	teamID := e.addTeam(owner)
	e.addMember(teamID, memberID)
	foreign := e.addTeam(member)

	got := items(t, e.do(http.MethodGet, "/api/v1/teams", nil, bearer(owner)))
	if len(got) != 2 {
		t.Fatalf("команд: %d", len(got))
	}
	// Личное пространство первым.
	if got[0]["id"] != e.personalTeam(ownerID).String() || got[0]["is_personal"] != true {
		t.Errorf("первая команда = %v", got[0])
	}
	if got[1]["id"] != teamID.String() || got[1]["member_count"] != float64(2) || got[1]["role"] != "owner" {
		t.Errorf("вторая команда = %v", got[1])
	}

	got = items(t, e.do(http.MethodGet, "/api/v1/teams", nil, bearer(member)))
	if len(got) != 3 {
		t.Fatalf("команд участника: %d", len(got))
	}
	if got[1]["id"] != teamID.String() || got[1]["role"] != "member" {
		t.Errorf("команда участника = %v", got[1])
	}
	if got[2]["id"] != foreign.String() {
		t.Errorf("своя команда участника = %v", got[2])
	}
}

func TestListDeletedTeams(t *testing.T) {
	e := newEnv(t)
	_, owner := e.register("owner")
	memberID, member := e.register("member")
	teamID := e.addTeam(owner)
	expired := e.addTeam(owner)
	e.addMember(teamID, memberID)
	const deletedURL = "/api/v1/teams?deleted=true"

	if got := items(t, e.do(http.MethodGet, deletedURL, nil, bearer(owner))); len(got) != 0 {
		t.Errorf("удалённых команд до удаления: %d", len(got))
	}

	e.do(http.MethodDelete, teamPath(teamID), nil, bearer(owner)).wantStatus(t, http.StatusNoContent)
	e.exec("UPDATE teams SET deleted_at = now() - interval '31 days' WHERE id = $1", expired)

	got := items(t, e.do(http.MethodGet, deletedURL, nil, bearer(owner)))
	if len(got) != 1 || got[0]["id"] != teamID.String() {
		t.Fatalf("удалённые команды = %v", got)
	}
	if deletedAt, _ := got[0]["deleted_at"].(string); !strings.HasSuffix(deletedAt, "Z") {
		t.Errorf("deleted_at = %v", got[0]["deleted_at"])
	}

	// Участнику удалённая команда не показывается ни в одном из списков.
	if got := items(t, e.do(http.MethodGet, deletedURL, nil, bearer(member))); len(got) != 0 {
		t.Errorf("удалённые команды участника = %v", got)
	}
	if got := items(t, e.do(http.MethodGet, "/api/v1/teams", nil, bearer(member))); len(got) != 1 {
		t.Errorf("команды участника = %v", got)
	}
	// deleted=false — обычный список.
	if got := items(t, e.do(http.MethodGet, "/api/v1/teams?deleted=false", nil, bearer(owner))); len(got) != 1 {
		t.Errorf("команды владельца = %v", got)
	}
}

func TestGetTeam(t *testing.T) {
	e := newEnv(t)
	_, owner := e.register("owner")
	memberID, member := e.register("member")
	_, stranger := e.register("stranger")
	teamID := e.addTeam(owner)
	e.addMember(teamID, memberID)

	r := e.do(http.MethodGet, teamPath(teamID), nil, bearer(member))
	r.wantStatus(t, http.StatusOK)
	if v := r.json(t); v["id"] != teamID.String() || v["role"] != "member" || v["member_count"] != float64(2) {
		t.Errorf("тело = %s", r.body)
	}

	e.do(http.MethodGet, teamPath(teamID), nil, bearer(stranger)).wantProblem(t, http.StatusForbidden, "no_team_access")
	// Несуществующая команда неотличима от чужой.
	e.do(http.MethodGet, teamPath(uuid.New()), nil, bearer(stranger)).wantProblem(t, http.StatusForbidden, "no_team_access")
}

func TestTeamPlan(t *testing.T) {
	e := newEnv(t, func(cfg *config.Config) {
		cfg.Plans["pro"] = config.Plan{MaxMembers: 50}
	})
	_, token := e.register("owner")
	teamID := e.addTeam(token)
	plan := func() map[string]any {
		r := e.do(http.MethodGet, teamPath(teamID), nil, bearer(token))
		r.wantStatus(t, http.StatusOK)
		return r.json(t)["plan"].(map[string]any)
	}

	e.exec("UPDATE teams SET plan = 'pro' WHERE id = $1", teamID)
	if got := plan(); got["key"] != "pro" || got["max_members"] != float64(50) {
		t.Errorf("plan = %v", got)
	}
	// К неизвестному ключу применяются лимиты free.
	e.exec("UPDATE teams SET plan = 'legacy' WHERE id = $1", teamID)
	if got := plan(); got["key"] != "free" || got["max_members"] != float64(5) {
		t.Errorf("plan = %v", got)
	}
}

func TestUpdateTeam(t *testing.T) {
	e := newEnv(t)
	_, owner := e.register("owner")
	memberID, member := e.register("member")
	_, stranger := e.register("stranger")
	teamID := e.addTeam(owner)
	e.addMember(teamID, memberID)
	const auditCount = "SELECT count(*) FROM audit_events WHERE team_id = $1 AND event = 'team.updated'"

	body := map[string]string{"name": "new"}
	e.do(http.MethodPatch, teamPath(teamID), body, bearer(member)).wantProblem(t, http.StatusForbidden, "owner_only")
	e.do(http.MethodPatch, teamPath(teamID), body, bearer(stranger)).wantProblem(t, http.StatusForbidden, "no_team_access")

	// Отсутствующее поле не меняется.
	e.do(http.MethodPatch, teamPath(teamID), map[string]string{"description": "about"}, bearer(owner)).wantStatus(t, http.StatusOK)
	r := e.do(http.MethodPatch, teamPath(teamID), body, bearer(owner))
	r.wantStatus(t, http.StatusOK)
	if v := r.json(t); v["name"] != "new" || v["description"] != "about" || v["role"] != "owner" {
		t.Errorf("тело = %s", r.body)
	}
	if n := e.count(auditCount, teamID); n != 2 {
		t.Errorf("записей team.updated: %d", n)
	}
	if n := e.count(`SELECT count(*) FROM audit_events WHERE team_id = $1 AND event = 'team.updated' AND actor_id = (
		SELECT user_id FROM team_members WHERE team_id = $1 AND role = 'owner')
		AND details = '{"name": {"from": "studio", "to": "new"}}'`, teamID); n != 1 {
		t.Error("в журнале нет было / стало для названия")
	}

	// Описание можно очистить, а запрос без изменений не попадает в журнал.
	r = e.do(http.MethodPatch, teamPath(teamID), map[string]string{"description": ""}, bearer(owner))
	r.wantStatus(t, http.StatusOK)
	if got := r.json(t)["description"]; got != "" {
		t.Errorf("description = %v", got)
	}
	before := e.count(auditCount, teamID)
	e.do(http.MethodPatch, teamPath(teamID), "{}", bearer(owner)).wantStatus(t, http.StatusOK)
	e.do(http.MethodPatch, teamPath(teamID), body, bearer(owner)).wantStatus(t, http.StatusOK)
	if n := e.count(auditCount, teamID); n != before {
		t.Errorf("запись в журнале без изменений: %d, было %d", n, before)
	}
}

func TestDeleteAndRestoreTeam(t *testing.T) {
	e := newEnv(t)
	ownerID, owner := e.register("owner")
	memberID, member := e.register("member")
	_, stranger := e.register("stranger")
	teamID := e.addTeam(owner)
	e.addMember(teamID, memberID)

	e.do(http.MethodDelete, teamPath(teamID), nil, bearer(member)).wantProblem(t, http.StatusForbidden, "owner_only")
	e.do(http.MethodDelete, teamPath(teamID), nil, bearer(stranger)).wantProblem(t, http.StatusForbidden, "no_team_access")
	e.do(http.MethodDelete, teamPath(e.personalTeam(ownerID)), nil, bearer(owner)).
		wantProblem(t, http.StatusConflict, "personal_team")

	// Восстанавливать нечего, пока команда не удалена.
	e.do(http.MethodPost, teamPath(teamID, "/restore"), nil, bearer(owner)).wantProblem(t, http.StatusNotFound, "not_found")

	e.do(http.MethodDelete, teamPath(teamID), nil, bearer(owner)).wantStatus(t, http.StatusNoContent)

	// Удалённая команда недоступна никому и ни для чего, кроме восстановления.
	for _, token := range []string{owner, member} {
		e.do(http.MethodGet, teamPath(teamID), nil, bearer(token)).wantProblem(t, http.StatusForbidden, "no_team_access")
		e.do(http.MethodGet, teamPath(teamID, "/members"), nil, bearer(token)).wantProblem(t, http.StatusForbidden, "no_team_access")
		e.do(http.MethodPatch, teamPath(teamID), "{}", bearer(token)).wantProblem(t, http.StatusForbidden, "no_team_access")
		e.do(http.MethodDelete, teamPath(teamID), nil, bearer(token)).wantProblem(t, http.StatusForbidden, "no_team_access")
		e.do(http.MethodPost, teamPath(teamID, "/leave"), nil, bearer(token)).wantProblem(t, http.StatusForbidden, "no_team_access")
	}

	e.do(http.MethodPost, teamPath(teamID, "/restore"), nil, bearer(member)).wantProblem(t, http.StatusForbidden, "owner_only")
	e.do(http.MethodPost, teamPath(teamID, "/restore"), nil, bearer(stranger)).wantProblem(t, http.StatusForbidden, "no_team_access")
	e.do(http.MethodPost, teamPath(uuid.New(), "/restore"), nil, bearer(owner)).wantProblem(t, http.StatusForbidden, "no_team_access")

	r := e.do(http.MethodPost, teamPath(teamID, "/restore"), nil, bearer(owner))
	r.wantStatus(t, http.StatusOK)
	if v := r.json(t); v["id"] != teamID.String() || v["deleted_at"] != nil || v["member_count"] != float64(2) {
		t.Errorf("тело = %s", r.body)
	}
	e.do(http.MethodGet, teamPath(teamID), nil, bearer(member)).wantStatus(t, http.StatusOK)

	// По истечении 30 суток восстановить нельзя.
	e.do(http.MethodDelete, teamPath(teamID), nil, bearer(owner)).wantStatus(t, http.StatusNoContent)
	e.exec("UPDATE teams SET deleted_at = $2 WHERE id = $1", teamID, time.Now().Add(-teamRestorePeriod-time.Minute))
	e.do(http.MethodPost, teamPath(teamID, "/restore"), nil, bearer(owner)).wantProblem(t, http.StatusNotFound, "not_found")
}

func TestTransferOwnership(t *testing.T) {
	e := newEnv(t)
	ownerID, owner := e.register("owner")
	memberID, member := e.register("member")
	strangerID, stranger := e.register("stranger")
	teamID := e.addTeam(owner)
	e.addMember(teamID, memberID)
	path := teamPath(teamID, "/transfer-ownership")
	to := func(id uuid.UUID) map[string]string { return map[string]string{"user_id": id.String()} }

	e.do(http.MethodPost, path, to(ownerID), bearer(member)).wantProblem(t, http.StatusForbidden, "owner_only")
	e.do(http.MethodPost, path, to(memberID), bearer(stranger)).wantProblem(t, http.StatusForbidden, "no_team_access")
	e.do(http.MethodPost, path, to(strangerID), bearer(owner)).wantProblem(t, http.StatusConflict, "not_a_member")
	e.do(http.MethodPost, path, to(ownerID), bearer(owner)).wantProblem(t, http.StatusBadRequest, "validation_error")
	e.do(http.MethodPost, path, map[string]string{"user_id": "x"}, bearer(owner)).wantProblem(t, http.StatusBadRequest, "validation_error")
	e.do(http.MethodPost, teamPath(e.personalTeam(ownerID), "/transfer-ownership"), to(memberID), bearer(owner)).
		wantProblem(t, http.StatusConflict, "personal_team")

	r := e.do(http.MethodPost, path, to(memberID), bearer(owner))
	r.wantStatus(t, http.StatusOK)
	if got := r.json(t)["role"]; got != "member" {
		t.Errorf("роль прежнего владельца в ответе = %v", got)
	}
	if n := e.count("SELECT count(*) FROM team_members WHERE team_id = $1 AND user_id = $2 AND role = 'owner'", teamID, memberID); n != 1 {
		t.Error("новый владелец не назначен")
	}
	if n := e.count("SELECT count(*) FROM team_members WHERE team_id = $1 AND user_id = $2 AND role = 'member'", teamID, ownerID); n != 1 {
		t.Error("прежний владелец не стал участником")
	}
	if n := e.count(`SELECT count(*) FROM audit_events WHERE team_id = $1 AND event = 'team.ownership_transferred'
		AND actor_id = $2 AND subject_user_id = $3 AND details ->> 'previous_owner' = $4`, teamID, ownerID, memberID, ownerID.String()); n != 1 {
		t.Error("передача владения не записана в журнал")
	}

	// Права перешли вместе с ролью.
	e.do(http.MethodPatch, teamPath(teamID), map[string]string{"name": "x"}, bearer(owner)).wantProblem(t, http.StatusForbidden, "owner_only")
	e.do(http.MethodPatch, teamPath(teamID), map[string]string{"name": "x"}, bearer(member)).wantStatus(t, http.StatusOK)
	// Прежний владелец теперь может выйти.
	e.do(http.MethodPost, teamPath(teamID, "/leave"), nil, bearer(owner)).wantStatus(t, http.StatusNoContent)
}

func TestLeaveTeam(t *testing.T) {
	e := newEnv(t)
	ownerID, owner := e.register("owner")
	memberID, member := e.register("member")
	_, stranger := e.register("stranger")
	teamID := e.addTeam(owner)
	e.addMember(teamID, memberID)
	path := teamPath(teamID, "/leave")

	e.do(http.MethodPost, path, nil, bearer(owner)).wantProblem(t, http.StatusConflict, "owner_cannot_leave")
	e.do(http.MethodPost, path, nil, bearer(stranger)).wantProblem(t, http.StatusForbidden, "no_team_access")
	e.do(http.MethodPost, teamPath(e.personalTeam(ownerID), "/leave"), nil, bearer(owner)).
		wantProblem(t, http.StatusConflict, "personal_team")

	e.do(http.MethodPost, path, nil, bearer(member)).wantStatus(t, http.StatusNoContent)

	if n := e.count(`SELECT count(*) FROM audit_events WHERE team_id = $1 AND event = 'member.left'
		AND actor_id = $2 AND subject_user_id = $2`, teamID, memberID); n != 1 {
		t.Error("выход не записан в журнал")
	}
	// Доступ закрывается сразу.
	e.do(http.MethodGet, teamPath(teamID), nil, bearer(member)).wantProblem(t, http.StatusForbidden, "no_team_access")
	e.do(http.MethodPost, path, nil, bearer(member)).wantProblem(t, http.StatusForbidden, "no_team_access")
}

func TestListMembers(t *testing.T) {
	e := newEnv(t)
	ownerID, owner := e.register("owner")
	memberID, member := e.register("member")
	goneID, _ := e.register("gone")
	_, stranger := e.register("stranger")
	teamID := e.addTeam(owner)
	e.addMember(teamID, memberID)
	e.addMember(teamID, goneID)
	// Вступившие раньше владельца не должны оказаться перед ним.
	e.exec("UPDATE team_members SET joined_at = now() + interval '1 hour' WHERE team_id = $1 AND user_id = $2", teamID, ownerID)
	e.exec("UPDATE team_members SET joined_at = now() + interval '1 minute' WHERE team_id = $1 AND user_id = $2", teamID, goneID)
	// Строка могла остаться только у обезличенного пользователя; ник такого не показывается.
	e.exec("UPDATE users SET deleted_at = now() WHERE id = $1", goneID)

	e.do(http.MethodGet, teamPath(teamID, "/members"), nil, bearer(stranger)).wantProblem(t, http.StatusForbidden, "no_team_access")

	got := items(t, e.do(http.MethodGet, teamPath(teamID, "/members"), nil, bearer(member)))
	if len(got) != 3 {
		t.Fatalf("участников: %d", len(got))
	}
	want := []struct {
		id       uuid.UUID
		nickname any
		role     string
	}{{ownerID, "owner", "owner"}, {memberID, "member", "member"}, {goneID, nil, "member"}}
	for i, w := range want {
		user := got[i]["user"].(map[string]any)
		if user["id"] != w.id.String() || user["nickname"] != w.nickname || got[i]["role"] != w.role {
			t.Errorf("участник %d = %v", i, got[i])
		}
		if _, present := user["nickname"]; !present {
			t.Errorf("nickname должен присутствовать: %v", user)
		}
		if joined, _ := got[i]["joined_at"].(string); !strings.HasSuffix(joined, "Z") {
			t.Errorf("joined_at = %v", got[i]["joined_at"])
		}
	}
}

func TestRemoveMember(t *testing.T) {
	e := newEnv(t)
	ownerID, owner := e.register("owner")
	memberID, member := e.register("member")
	otherID, other := e.register("other")
	strangerID, stranger := e.register("stranger")
	teamID := e.addTeam(owner)
	e.addMember(teamID, memberID)
	e.addMember(teamID, otherID)
	path := func(id uuid.UUID) string { return teamPath(teamID, "/members/", id.String()) }

	e.do(http.MethodDelete, path(otherID), nil, bearer(member)).wantProblem(t, http.StatusForbidden, "owner_only")
	e.do(http.MethodDelete, path(otherID), nil, bearer(stranger)).wantProblem(t, http.StatusForbidden, "no_team_access")
	e.do(http.MethodDelete, path(ownerID), nil, bearer(owner)).wantProblem(t, http.StatusConflict, "owner_cannot_leave")
	e.do(http.MethodDelete, path(strangerID), nil, bearer(owner)).wantProblem(t, http.StatusNotFound, "not_found")

	// Кабель, за который отвечает исключаемый: ответственный сбрасывается, версия и счётчик растут.
	e.exec("UPDATE teams SET change_seq = 5 WHERE id = $1", teamID)
	cableID := uuid.New()
	e.exec(`INSERT INTO cables (id, team_id, name, cable_type, color, assignee_id, created_by, created_at, change_seq)
		VALUES ($1, $2, 'c', 'xlr', 'ff0000', $3, $3, now(), 1)`, cableID, teamID, memberID)

	e.do(http.MethodDelete, path(memberID), nil, bearer(owner)).wantStatus(t, http.StatusNoContent)

	if n := e.count("SELECT count(*) FROM team_members WHERE team_id = $1 AND user_id = $2", teamID, memberID); n != 0 {
		t.Error("участник не исключён")
	}
	if n := e.count("SELECT count(*) FROM cables WHERE id = $1 AND assignee_id IS NULL AND version = 2 AND change_seq = 6", cableID); n != 1 {
		t.Error("ответственный не сброшен")
	}
	// В журнале действие от имени владельца.
	if n := e.count(`SELECT count(*) FROM audit_events WHERE team_id = $1 AND event = 'member.removed'
		AND actor_id = $2 AND subject_user_id = $3`, teamID, ownerID, memberID); n != 1 {
		t.Error("исключение не записано в журнал")
	}
	if n := e.count(`SELECT count(*) FROM audit_events WHERE team_id = $1 AND event = 'cable.assignee_changed'
		AND actor_id = $2 AND subject_user_id = $3 AND cable_id = $4`, teamID, ownerID, memberID, cableID); n != 1 {
		t.Error("сброс ответственного не записан в журнал")
	}
	if n := e.count("SELECT count(*) FROM audit_events WHERE team_id = $1 AND event = 'member.left'", teamID); n != 0 {
		t.Errorf("записей member.left: %d", n)
	}

	// Доступ закрывается сразу, остальных это не касается.
	e.do(http.MethodGet, teamPath(teamID), nil, bearer(member)).wantProblem(t, http.StatusForbidden, "no_team_access")
	e.do(http.MethodGet, teamPath(teamID), nil, bearer(other)).wantStatus(t, http.StatusOK)
	// Повторное исключение — участника уже нет.
	e.do(http.MethodDelete, path(memberID), nil, bearer(owner)).wantProblem(t, http.StatusNotFound, "not_found")
}
