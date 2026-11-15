package server

import (
	"net/http"
	"strings"
	"testing"

	"github.com/google/uuid"
)

func invitationPath(suffix ...string) string {
	return "/api/v1/invitations" + strings.Join(suffix, "")
}

func byTokenPath(token string, suffix ...string) string {
	return invitationPath("/by-token/", token) + strings.Join(suffix, "")
}

// createInvitation создаёт приглашение через API и возвращает токен и ID приглашения.
func (e *testEnv) createInvitation(token string, teamID uuid.UUID, body any) (string, uuid.UUID) {
	e.t.Helper()
	if body == nil {
		body = map[string]any{}
	}
	r := e.do(http.MethodPost, teamPath(teamID, "/invitations"), body, bearer(token))
	r.wantStatus(e.t, http.StatusCreated)
	v := r.json(e.t)
	tok, _ := v["token"].(string)
	if tok == "" {
		e.t.Fatalf("токен пуст: %s", r.body)
	}
	id, err := uuid.Parse(v["invitation"].(map[string]any)["id"].(string))
	if err != nil {
		e.t.Fatal(err)
	}
	return tok, id
}

func TestInvitationRoutesRequireSession(t *testing.T) {
	id := uuid.NewString()
	tok := "some-token"
	routes := []struct{ method, path string }{
		{http.MethodGet, "/api/v1/teams/" + id + "/invitations"},
		{http.MethodPost, "/api/v1/teams/" + id + "/invitations"},
		{http.MethodDelete, invitationPath("/", id)},
		{http.MethodPost, byTokenPath(tok, "/accept")},
	}
	e := newEnv(t)
	for _, route := range routes {
		t.Run(route.method+" "+route.path, func(t *testing.T) {
			e.do(route.method, route.path, "{}").wantProblem(t, http.StatusUnauthorized, "unauthorized")
		})
	}
}

func TestInvitationPreviewIsPublic(t *testing.T) {
	e := newEnv(t)
	// Предпросмотр без входа: несуществующий токен даёт invitation_invalid, а не unauthorized.
	e.do(http.MethodGet, byTokenPath("no-such-token"), nil).wantProblem(t, http.StatusNotFound, "invitation_invalid")
}

func TestCreateAndListInvitation(t *testing.T) {
	e := newEnv(t)
	ownerID, owner := e.register("owner")
	memberID, member := e.register("member")
	_, stranger := e.register("stranger")
	teamID := e.addTeam(owner)
	e.addMember(teamID, memberID)

	// В личное пространство приглашать нельзя.
	e.do(http.MethodPost, teamPath(e.personalTeam(ownerID), "/invitations"), map[string]any{}, bearer(owner)).
		wantProblem(t, http.StatusConflict, "personal_team")

	// Срок вне диапазона.
	e.do(http.MethodPost, teamPath(teamID, "/invitations"), map[string]any{"expires_in_days": 31}, bearer(owner)).
		wantProblem(t, http.StatusBadRequest, "validation_error")
	e.do(http.MethodPost, teamPath(teamID, "/invitations"), map[string]any{"expires_in_days": 0}, bearer(owner)).
		wantProblem(t, http.StatusBadRequest, "validation_error")

	token, invitationID := e.createInvitation(owner, teamID, nil)
	if len(token) != 43 {
		t.Errorf("токен = %q, ожидалась длина 43", token)
	}

	// Список виден только владельцу.
	list := func(auth string) []map[string]any {
		return items(t, e.do(http.MethodGet, teamPath(teamID, "/invitations"), nil, bearer(auth)))
	}
	e.do(http.MethodGet, teamPath(teamID, "/invitations"), nil, bearer(member)).wantProblem(t, http.StatusForbidden, "owner_only")
	e.do(http.MethodGet, teamPath(teamID, "/invitations"), nil, bearer(stranger)).wantProblem(t, http.StatusForbidden, "no_team_access")

	got := list(owner)
	if len(got) != 1 {
		t.Fatalf("приглашений: %d", len(got))
	}
	inv := got[0]
	if inv["id"] != invitationID.String() || inv["team_id"] != teamID.String() {
		t.Errorf("приглашение = %v", inv)
	}
	createdBy := inv["created_by"].(map[string]any)
	if createdBy["id"] != ownerID.String() || createdBy["nickname"] != "owner" {
		t.Errorf("created_by = %v", createdBy)
	}
	if expires, _ := inv["expires_at"].(string); !strings.HasSuffix(expires, "Z") {
		t.Errorf("expires_at не в UTC: %v", inv["expires_at"])
	}

	// Токен в БД не хранится — только его хеш.
	if n := e.count("SELECT count(*) FROM invitations WHERE token_hash = decode(repeat('00', 64), 'hex')"); n != 0 {
		t.Error("в БД оказался нулевой хеш токена")
	}
	if n := e.count("SELECT count(*) FROM invitations WHERE id = $1 AND used_at IS NULL AND revoked_at IS NULL", invitationID); n != 1 {
		t.Errorf("приглашение не записано: %d", n)
	}
	if n := e.count(`SELECT count(*) FROM audit_events WHERE team_id = $1 AND event = 'invitation.created'
        AND actor_id = $2 AND details ->> 'id' = $3`, teamID, ownerID, invitationID.String()); n != 1 {
		t.Error("создание не записано в журнал")
	}
}

func TestInvitationPreview(t *testing.T) {
	e := newEnv(t)
	_, owner := e.register("owner")
	teamID := e.addTeam(owner)
	token, _ := e.createInvitation(owner, teamID, map[string]any{"expires_in_days": 7})

	// Предпросмотр без входа.
	r := e.do(http.MethodGet, byTokenPath(token), nil)
	r.wantStatus(t, http.StatusOK)
	if v := r.json(t); v["team_name"] != "studio" {
		t.Errorf("team_name = %v", v)
	}

	// Чужой токен.
	e.do(http.MethodGet, byTokenPath("not-the-token"), nil).wantProblem(t, http.StatusNotFound, "invitation_invalid")
}

func TestAcceptInvitation(t *testing.T) {
	e := newEnv(t)
	ownerID, owner := e.register("owner")
	memberID, member := e.register("member")
	joinerID, joiner := e.register("joiner")
	teamID := e.addTeam(owner)
	e.addMember(teamID, memberID)
	token, invitationID := e.createInvitation(owner, teamID, nil)

	// Уже участник — вступать не нужно.
	e.do(http.MethodPost, byTokenPath(token, "/accept"), nil, bearer(member)).
		wantProblem(t, http.StatusConflict, "already_member")
	// Приглашение не потрачено на уже участника.
	if n := e.count("SELECT count(*) FROM invitations WHERE id = $1 AND used_at IS NULL", invitationID); n != 1 {
		t.Errorf("приглашение потрачено на уже участника: %d", n)
	}

	// Вступление.
	r := e.do(http.MethodPost, byTokenPath(token, "/accept"), nil, bearer(joiner))
	r.wantStatus(t, http.StatusOK)
	if v := r.json(t); v["id"] != teamID.String() || v["role"] != "member" || v["member_count"] != float64(3) {
		t.Errorf("тело = %s", r.body)
	}
	if n := e.count("SELECT count(*) FROM team_members WHERE team_id = $1 AND user_id = $2 AND role = 'member'", teamID, joinerID); n != 1 {
		t.Error("вступивший не добавлен участником")
	}
	if n := e.count("SELECT count(*) FROM invitations WHERE id = $1 AND used_by = $2 AND used_at IS NOT NULL", invitationID, joinerID); n != 1 {
		t.Error("приглашение не помечено использованным")
	}
	if n := e.count(`SELECT count(*) FROM audit_events WHERE team_id = $1 AND event = 'member.joined'
        AND actor_id = $2 AND subject_user_id = $2 AND details ->> 'invitation_id' = $3`, teamID, joinerID, invitationID.String()); n != 1 {
		t.Error("вступление не записано в журнал")
	}

	// Одноразовость: тот же токен больше не действует.
	e.do(http.MethodPost, byTokenPath(token, "/accept"), nil, bearer(joiner)).
		wantProblem(t, http.StatusNotFound, "invitation_invalid")
	// Уже участник повторно принимает — тоже invitation_invalid (приглашение использовано), а не already_member.
	_, fresh := e.register("fresh")
	e.do(http.MethodPost, byTokenPath(token, "/accept"), nil, bearer(fresh)).
		wantProblem(t, http.StatusNotFound, "invitation_invalid")
	// Доступ к команде у вступившего есть.
	e.do(http.MethodGet, teamPath(teamID), nil, bearer(joiner)).wantStatus(t, http.StatusOK)
	_ = ownerID
}

func TestAcceptInvitationMemberLimit(t *testing.T) {
	e := newEnv(t)
	_, owner := e.register("owner")
	teamID := e.addTeam(owner)
	// free: 5 участников. Владелец + четверо = лимит исчерпан.
	for _, name := range []string{"mara", "marb", "marc", "mard"} {
		id, _ := e.register(name)
		e.addMember(teamID, id)
	}
	token, invitationID := e.createInvitation(owner, teamID, nil)
	_, joiner := e.register("joiner")

	e.do(http.MethodPost, byTokenPath(token, "/accept"), nil, bearer(joiner)).
		wantProblem(t, http.StatusConflict, "member_limit_reached")
	// Шестой не вступил, приглашение не потрачено.
	if n := e.count("SELECT count(*) FROM team_members WHERE team_id = $1", teamID); n != 5 {
		t.Errorf("участников: %d, ожидалось 5", n)
	}
	if n := e.count("SELECT count(*) FROM invitations WHERE id = $1 AND used_at IS NULL", invitationID); n != 1 {
		t.Errorf("приглашение потрачено при отказе по лимиту: %d", n)
	}
}

func TestRevokeInvitation(t *testing.T) {
	e := newEnv(t)
	ownerID, owner := e.register("owner")
	memberID, member := e.register("member")
	_, stranger := e.register("stranger")
	teamID := e.addTeam(owner)
	e.addMember(teamID, memberID)
	token, invitationID := e.createInvitation(owner, teamID, nil)
	path := invitationPath("/", invitationID.String())

	// Не владельцу команды — нельзя; чужому — not_found.
	e.do(http.MethodDelete, path, nil, bearer(member)).wantProblem(t, http.StatusForbidden, "owner_only")
	e.do(http.MethodDelete, path, nil, bearer(stranger)).wantProblem(t, http.StatusNotFound, "not_found")
	e.do(http.MethodDelete, invitationPath("/", uuid.New().String()), nil, bearer(owner)).
		wantProblem(t, http.StatusNotFound, "not_found")

	// Отзыв.
	e.do(http.MethodDelete, path, nil, bearer(owner)).wantStatus(t, http.StatusNoContent)
	if n := e.count("SELECT count(*) FROM invitations WHERE id = $1 AND revoked_at IS NOT NULL", invitationID); n != 1 {
		t.Error("приглашение не отозвано")
	}
	if n := e.count(`SELECT count(*) FROM audit_events WHERE team_id = $1 AND event = 'invitation.revoked'
        AND actor_id = $2 AND details ->> 'id' = $3`, teamID, ownerID, invitationID.String()); n != 1 {
		t.Error("отзыв не записан в журнал")
	}
	// Отозванное не показывается в списке.
	if got := items(t, e.do(http.MethodGet, teamPath(teamID, "/invitations"), nil, bearer(owner))); len(got) != 0 {
		t.Errorf("отозванное приглашение в списке: %v", got)
	}
	// Отозванное нельзя принять и предпросмотреть.
	e.do(http.MethodGet, byTokenPath(token), nil).wantProblem(t, http.StatusNotFound, "invitation_invalid")
	e.do(http.MethodPost, byTokenPath(token, "/accept"), nil, bearer(member)).
		wantProblem(t, http.StatusNotFound, "invitation_invalid")

	// Повторный отзыв — 204 без новой записи в журнале.
	before := e.count(`SELECT count(*) FROM audit_events WHERE team_id = $1 AND event = 'invitation.revoked'`, teamID)
	e.do(http.MethodDelete, path, nil, bearer(owner)).wantStatus(t, http.StatusNoContent)
	if n := e.count(`SELECT count(*) FROM audit_events WHERE team_id = $1 AND event = 'invitation.revoked'`, teamID); n != before {
		t.Errorf("повторный отзыв добавил запись: %d, было %d", n, before)
	}
}

func TestInvitationExpiry(t *testing.T) {
	e := newEnv(t)
	_, owner := e.register("owner")
	_, joiner := e.register("joiner")
	teamID := e.addTeam(owner)
	token, invitationID := e.createInvitation(owner, teamID, map[string]any{"expires_in_days": 1})

	// Срок ещё не истёк — предпросмотр работает.
	e.do(http.MethodGet, byTokenPath(token), nil).wantStatus(t, http.StatusOK)
	// Сдвигаем expires_at в прошлое.
	e.exec("UPDATE invitations SET expires_at = now() - interval '1 minute' WHERE id = $1", invitationID)

	e.do(http.MethodGet, byTokenPath(token), nil).wantProblem(t, http.StatusNotFound, "invitation_invalid")
	e.do(http.MethodPost, byTokenPath(token, "/accept"), nil, bearer(joiner)).
		wantProblem(t, http.StatusNotFound, "invitation_invalid")
	// Истёкшее не показывается в списке.
	if got := items(t, e.do(http.MethodGet, teamPath(teamID, "/invitations"), nil, bearer(owner))); len(got) != 0 {
		t.Errorf("истёкшее приглашение в списке: %v", got)
	}
}
