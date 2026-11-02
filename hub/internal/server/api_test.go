package server

import (
	"bytes"
	"context"
	"crypto/hmac"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"io"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"os"
	"strconv"
	"strings"
	"sync"
	"testing"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"

	"git.hakoniwa.ru/tech/himodameshi/hub/internal/auth"
	"git.hakoniwa.ru/tech/himodameshi/hub/internal/config"
	"git.hakoniwa.ru/tech/himodameshi/hub/internal/migrations"
)

const (
	testPublicURL = "https://himo.test"
	testBotToken  = "123:test-bot-token" // gitleaks:allow
	testPassword  = "correct-horse"
)

var migrateOnce sync.Once

type testEnv struct {
	t       *testing.T
	db      *pgxpool.Pool
	server  *Server
	handler http.Handler
}

// newEnv поднимает сервер на настоящем PostgreSQL из TEST_DATABASE_URL с пустыми таблицами.
func newEnv(t *testing.T, change ...func(*config.Config)) *testEnv {
	t.Helper()
	gin.SetMode(gin.TestMode)

	url := os.Getenv("TEST_DATABASE_URL")
	if url == "" {
		t.Skip("TEST_DATABASE_URL не задан")
	}
	ctx := context.Background()
	db, err := pgxpool.New(ctx, url)
	if err != nil {
		t.Fatal(err)
	}
	t.Cleanup(db.Close)

	migrateOnce.Do(func() {
		if err := migrations.Up(ctx, db); err != nil {
			t.Fatal(err)
		}
	})
	if _, err := db.Exec(ctx, "TRUNCATE users, teams CASCADE"); err != nil {
		t.Fatal(err)
	}

	cfg := config.Config{
		PublicURL:        testPublicURL + "/",
		TelegramBotToken: testBotToken,
		Plans:            config.Plans{config.FreePlan: {MaxMembers: 5}},
	}
	for _, f := range change {
		f(&cfg)
	}
	s := New(db, cfg, slog.New(slog.NewJSONHandler(io.Discard, nil)))
	handler, err := s.Handler()
	if err != nil {
		t.Fatal(err)
	}
	return &testEnv{t: t, db: db, server: s, handler: handler}
}

type response struct {
	code   int
	header http.Header
	body   []byte
}

func (r response) json(t *testing.T) map[string]any {
	t.Helper()
	var v map[string]any
	if err := json.Unmarshal(r.body, &v); err != nil {
		t.Fatalf("тело %q: %v", r.body, err)
	}
	return v
}

// wantProblem проверяет код ответа и формат ошибки RFC 9457.
func (r response) wantProblem(t *testing.T, status int, code string) {
	t.Helper()
	if r.code != status {
		t.Fatalf("код ответа = %d, ожидался %d; тело %s", r.code, status, r.body)
	}
	if got := r.header.Get("Content-Type"); got != "application/problem+json" {
		t.Errorf("Content-Type = %q", got)
	}
	v := r.json(t)
	if v["code"] != code || v["type"] != "about:blank" || v["status"] != float64(status) || v["title"] != http.StatusText(status) {
		t.Errorf("тело ошибки = %s, ожидался code %q", r.body, code)
	}
}

func (r response) wantStatus(t *testing.T, status int) {
	t.Helper()
	if r.code != status {
		t.Fatalf("код ответа = %d, ожидался %d; тело %s", r.code, status, r.body)
	}
}

type requestOption func(*http.Request)

func bearer(token string) requestOption {
	return func(r *http.Request) { r.Header.Set("Authorization", "Bearer "+token) }
}

func cookie(token string) requestOption {
	return func(r *http.Request) { r.AddCookie(&http.Cookie{Name: sessionCookieName, Value: token}) }
}

func header(name, value string) requestOption {
	return func(r *http.Request) { r.Header.Set(name, value) }
}

func (e *testEnv) do(method, path string, body any, opts ...requestOption) response {
	e.t.Helper()
	var reader io.Reader
	switch b := body.(type) {
	case nil:
	case string:
		reader = strings.NewReader(b)
	default:
		data, err := json.Marshal(b)
		if err != nil {
			e.t.Fatal(err)
		}
		reader = bytes.NewReader(data)
	}
	req := httptest.NewRequest(method, path, reader)
	req.Header.Set("Content-Type", "application/json")
	for _, opt := range opts {
		opt(req)
	}
	rec := httptest.NewRecorder()
	e.handler.ServeHTTP(rec, req)
	return response{code: rec.Code, header: rec.Header(), body: rec.Body.Bytes()}
}

// register создаёт пользователя и возвращает его ID и токен приложения.
func (e *testEnv) register(nickname string) (id uuid.UUID, token string) {
	e.t.Helper()
	r := e.do(http.MethodPost, "/api/v1/auth/register", map[string]string{
		"nickname": nickname, "password": testPassword, "client": "app",
	})
	r.wantStatus(e.t, http.StatusCreated)
	v := r.json(e.t)
	id, err := uuid.Parse(v["user"].(map[string]any)["id"].(string))
	if err != nil {
		e.t.Fatal(err)
	}
	return id, v["token"].(string)
}

func (e *testEnv) login(nickname, password string, opts ...requestOption) response {
	e.t.Helper()
	return e.do(http.MethodPost, "/api/v1/auth/login", map[string]string{
		"nickname": nickname, "password": password, "client": "app",
	}, opts...)
}

func (e *testEnv) count(sql string, args ...any) int {
	e.t.Helper()
	var n int
	if err := e.db.QueryRow(context.Background(), sql, args...).Scan(&n); err != nil {
		e.t.Fatal(err)
	}
	return n
}

func (e *testEnv) exec(sql string, args ...any) {
	e.t.Helper()
	if _, err := e.db.Exec(context.Background(), sql, args...); err != nil {
		e.t.Fatal(err)
	}
}

// webCookie входит как веб-клиент и возвращает значение cookie.
func (e *testEnv) webCookie(nickname string) string {
	e.t.Helper()
	r := e.do(http.MethodPost, "/api/v1/auth/login", map[string]string{
		"nickname": nickname, "password": testPassword, "client": "web",
	})
	r.wantStatus(e.t, http.StatusOK)
	value, _, _ := strings.Cut(strings.TrimPrefix(r.header.Get("Set-Cookie"), sessionCookieName+"="), ";")
	return value
}

func telegramData(id int64, authDate time.Time) map[string]any {
	date := authDate.Unix()
	check := "auth_date=" + strconv.FormatInt(date, 10) + "\nfirst_name=Vlad\nid=" + strconv.FormatInt(id, 10) + "\nusername=vlad_tg"
	key := sha256.Sum256([]byte(testBotToken))
	mac := hmac.New(sha256.New, key[:])
	mac.Write([]byte(check))
	return map[string]any{
		"id": id, "first_name": "Vlad", "username": "vlad_tg", "auth_date": date,
		"hash": hex.EncodeToString(mac.Sum(nil)),
	}
}

func TestRegisterApp(t *testing.T) {
	e := newEnv(t)
	r := e.do(http.MethodPost, "/api/v1/auth/register", map[string]string{
		"nickname": "Vlad_1", "password": testPassword, "client": "app",
	})
	r.wantStatus(t, http.StatusCreated)
	if got := r.header.Values("Set-Cookie"); len(got) != 0 {
		t.Errorf("приложению поставлена cookie: %q", got)
	}

	v := r.json(t)
	user := v["user"].(map[string]any)
	if user["nickname"] != "Vlad_1" {
		t.Errorf("user = %v", user)
	}
	if telegram, present := user["telegram"]; !present || telegram != nil {
		t.Errorf("telegram должен присутствовать и быть null: %v", user)
	}
	id, err := uuid.Parse(user["id"].(string))
	if err != nil || id.Version() != 7 {
		t.Errorf("id %v не UUIDv7: %v", user["id"], err)
	}
	if !strings.HasSuffix(v["expires_at"].(string), "Z") {
		t.Errorf("expires_at не в UTC: %v", v["expires_at"])
	}
	token, _ := v["token"].(string)
	if len(token) != 43 {
		t.Fatalf("токен = %q", token)
	}

	// В БД — только хеши, создано личное пространство с единственным владельцем.
	if n := e.count("SELECT count(*) FROM auth_sessions WHERE token_hash = $1 AND client = 'app'", auth.HashToken(token)); n != 1 {
		t.Errorf("сеансов с хешем токена: %d", n)
	}
	if n := e.count("SELECT count(*) FROM users WHERE password_hash LIKE '$argon2id$%'"); n != 1 {
		t.Errorf("пользователей с хешем Argon2id: %d", n)
	}
	if n := e.count(`SELECT count(*) FROM teams t JOIN team_members m ON m.team_id = t.id
		WHERE t.is_personal AND m.user_id = $1 AND m.role = 'owner'`, id); n != 1 {
		t.Errorf("личных пространств: %d", n)
	}

	e.do(http.MethodGet, "/api/v1/me", nil, bearer(token)).wantStatus(t, http.StatusOK)
}

func TestRegisterWeb(t *testing.T) {
	e := newEnv(t)
	r := e.do(http.MethodPost, "/api/v1/auth/register", map[string]string{
		"nickname": "vlad", "password": testPassword, "client": "web",
	})
	r.wantStatus(t, http.StatusCreated)
	if _, present := r.json(t)["token"]; present {
		t.Errorf("веб получил токен в теле: %s", r.body)
	}
	set := r.header.Get("Set-Cookie")
	for _, part := range []string{sessionCookieName + "=", "Path=/", "Max-Age=2592000", "HttpOnly", "Secure", "SameSite=Strict"} {
		if !strings.Contains(set, part) {
			t.Errorf("в Set-Cookie %q нет %q", set, part)
		}
	}
}

func TestRegisterNicknameTaken(t *testing.T) {
	e := newEnv(t)
	e.register("vlad")
	r := e.do(http.MethodPost, "/api/v1/auth/register", map[string]string{
		"nickname": "VLAD", "password": testPassword, "client": "app",
	})
	r.wantProblem(t, http.StatusConflict, "nickname_taken")
	// Неудачная регистрация откатывается целиком.
	if n := e.count("SELECT count(*) FROM teams"); n != 1 {
		t.Errorf("команд: %d", n)
	}
}

func TestRegisterValidation(t *testing.T) {
	long := strings.Repeat("a", 129)
	tests := []struct {
		name  string
		body  any
		field string
	}{
		{"короткий ник", map[string]string{"nickname": "ab", "password": testPassword, "client": "app"}, "nickname"},
		{"ник с недопустимым символом", map[string]string{"nickname": "влад", "password": testPassword, "client": "app"}, "nickname"},
		{"ник длиннее 32", map[string]string{"nickname": strings.Repeat("a", 33), "password": testPassword, "client": "app"}, "nickname"},
		{"короткий пароль", map[string]string{"nickname": "vlad", "password": "1234567", "client": "app"}, "password"},
		{"длинный пароль", map[string]string{"nickname": "vlad", "password": long, "client": "app"}, "password"},
		{"неизвестный клиент", map[string]string{"nickname": "vlad", "password": testPassword, "client": "tv"}, "client"},
		{"битый JSON", "{", "body"},
		{"неверный тип поля", `{"nickname": 1}`, "body"},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			e := newEnv(t)
			r := e.do(http.MethodPost, "/api/v1/auth/register", tt.body)
			r.wantProblem(t, http.StatusBadRequest, "validation_error")
			errs := r.json(t)["errors"].([]any)
			if errs[0].(map[string]any)["field"] != tt.field {
				t.Errorf("errors = %v, ожидалось поле %q", errs, tt.field)
			}
		})
	}
}

func TestLogin(t *testing.T) {
	e := newEnv(t)
	id, _ := e.register("vlad")

	r := e.login("VLAD", testPassword) // ник без учёта регистра
	r.wantStatus(t, http.StatusOK)
	v := r.json(t)
	if v["token"] == "" || v["user"].(map[string]any)["id"] != id.String() {
		t.Errorf("тело = %s", r.body)
	}

	wrong := e.login("vlad", "wrong-password")
	wrong.wantProblem(t, http.StatusUnauthorized, "invalid_credentials")
	unknown := e.login("nobody", "wrong-password")
	unknown.wantProblem(t, http.StatusUnauthorized, "invalid_credentials")
	if !bytes.Equal(wrong.body, unknown.body) {
		t.Errorf("ответы различаются: %s и %s", wrong.body, unknown.body)
	}

	e.login("vlad", "short").wantProblem(t, http.StatusBadRequest, "validation_error")
	e.login("", testPassword).wantProblem(t, http.StatusBadRequest, "validation_error")
}

func TestAuthRateLimit(t *testing.T) {
	e := newEnv(t)
	for range authAttemptsLimit {
		e.login("nobody", "wrong-password").wantProblem(t, http.StatusUnauthorized, "invalid_credentials")
	}
	r := e.login("nobody", "wrong-password")
	r.wantProblem(t, http.StatusTooManyRequests, "rate_limited")
	if got, err := strconv.Atoi(r.header.Get("Retry-After")); err != nil || got < 1 || got > 60 {
		t.Errorf("Retry-After = %q", r.header.Get("Retry-After"))
	}

	// Попытки считаются вместе для всех маршрутов входа.
	e.do(http.MethodPost, "/api/v1/auth/register", map[string]string{
		"nickname": "vlad", "password": testPassword, "client": "app",
	}).wantProblem(t, http.StatusTooManyRequests, "rate_limited")

	// Через минуту окно открывается заново.
	e.server.now = func() time.Time { return time.Now().Add(authAttemptsPeriod) }
	e.login("nobody", "wrong-password").wantProblem(t, http.StatusUnauthorized, "invalid_credentials")
}

func TestClientIPFromTrustedProxyOnly(t *testing.T) {
	e := newEnv(t)
	// Без доверенных прокси подмена X-Forwarded-For не обходит ограничение.
	for i := range authAttemptsLimit {
		e.login("nobody", "wrong-password", header("X-Forwarded-For", "10.0.0."+strconv.Itoa(i)))
	}
	e.login("nobody", "wrong-password", header("X-Forwarded-For", "10.0.1.1")).
		wantProblem(t, http.StatusTooManyRequests, "rate_limited")
}

func TestSessionRequired(t *testing.T) {
	routes := []struct{ method, path string }{
		{http.MethodPost, "/api/v1/auth/logout"},
		{http.MethodPost, "/api/v1/auth/logout-all"},
		{http.MethodGet, "/api/v1/me"},
		{http.MethodPatch, "/api/v1/me"},
		{http.MethodDelete, "/api/v1/me"},
		{http.MethodPut, "/api/v1/me/password"},
		{http.MethodPut, "/api/v1/me/telegram"},
		{http.MethodDelete, "/api/v1/me/telegram"},
	}
	e := newEnv(t)
	for _, route := range routes {
		t.Run(route.method+" "+route.path, func(t *testing.T) {
			e.do(route.method, route.path, "{}").wantProblem(t, http.StatusUnauthorized, "unauthorized")
			e.do(route.method, route.path, "{}", bearer("no-such-token")).wantProblem(t, http.StatusUnauthorized, "unauthorized")
		})
	}
	e.do(http.MethodGet, "/api/v1/me", nil, header("Authorization", "Basic abc")).
		wantProblem(t, http.StatusUnauthorized, "unauthorized")
}

func TestExpiredSession(t *testing.T) {
	e := newEnv(t)
	_, token := e.register("vlad")
	e.exec("UPDATE auth_sessions SET expires_at = now() - interval '1 second'")
	e.do(http.MethodGet, "/api/v1/me", nil, bearer(token)).wantProblem(t, http.StatusUnauthorized, "unauthorized")
}

func TestSessionExtension(t *testing.T) {
	e := newEnv(t)
	_, token := e.register("vlad")
	web := e.webCookie("vlad")
	expires := func(tok string) time.Time {
		var at time.Time
		err := e.db.QueryRow(context.Background(),
			"SELECT expires_at FROM auth_sessions WHERE token_hash = $1", auth.HashToken(tok)).Scan(&at)
		if err != nil {
			t.Fatal(err)
		}
		return at
	}

	// Меньше суток с продления — срок не меняется и запроса на запись нет.
	before := expires(token)
	r := e.do(http.MethodGet, "/api/v1/me", nil, cookie(web))
	r.wantStatus(t, http.StatusOK)
	if got := r.header.Get("Set-Cookie"); got != "" {
		t.Errorf("cookie обновлена без продления: %q", got)
	}
	e.do(http.MethodGet, "/api/v1/me", nil, bearer(token)).wantStatus(t, http.StatusOK)
	if !expires(token).Equal(before) {
		t.Error("срок продлён раньше времени")
	}

	// Больше суток — срок снова 30 суток, веб-cookie обновляется вместе с ним.
	e.exec("UPDATE auth_sessions SET expires_at = now() + interval '28 days'")
	r = e.do(http.MethodGet, "/api/v1/me", nil, bearer(token))
	r.wantStatus(t, http.StatusOK)
	if got := r.header.Get("Set-Cookie"); got != "" {
		t.Errorf("приложению поставлена cookie: %q", got)
	}
	if left := time.Until(expires(token)); left < 29*24*time.Hour {
		t.Errorf("срок не продлён: осталось %v", left)
	}
	r = e.do(http.MethodGet, "/api/v1/me", nil, cookie(web))
	r.wantStatus(t, http.StatusOK)
	if got := r.header.Get("Set-Cookie"); !strings.Contains(got, web) || !strings.Contains(got, "Max-Age=2592000") {
		t.Errorf("Set-Cookie = %q", got)
	}
}

func TestCookieOriginCheck(t *testing.T) {
	e := newEnv(t)
	e.register("vlad")
	web := e.webCookie("vlad")
	body := map[string]string{"nickname": "vlad2"}

	// Чтение Origin не требует.
	e.do(http.MethodGet, "/api/v1/me", nil, cookie(web)).wantStatus(t, http.StatusOK)

	e.do(http.MethodPatch, "/api/v1/me", body, cookie(web)).wantProblem(t, http.StatusForbidden, "origin_mismatch")
	e.do(http.MethodPatch, "/api/v1/me", body, cookie(web), header("Origin", "https://dev.himo.test")).
		wantProblem(t, http.StatusForbidden, "origin_mismatch")
	e.do(http.MethodPatch, "/api/v1/me", body, cookie(web), header("Origin", testPublicURL)).
		wantStatus(t, http.StatusOK)

	// Bearer не подставляется браузером сам, проверка его не касается.
	_, token := e.register("other")
	e.do(http.MethodPatch, "/api/v1/me", map[string]string{"nickname": "other2"}, bearer(token)).wantStatus(t, http.StatusOK)
}

func TestLogout(t *testing.T) {
	e := newEnv(t)
	_, token := e.register("vlad")
	second := e.login("vlad", testPassword).json(t)["token"].(string)

	r := e.do(http.MethodPost, "/api/v1/auth/logout", nil, bearer(token))
	r.wantStatus(t, http.StatusNoContent)
	if got := r.header.Get("Set-Cookie"); got != "" {
		t.Errorf("Set-Cookie для приложения: %q", got)
	}
	e.do(http.MethodGet, "/api/v1/me", nil, bearer(token)).wantProblem(t, http.StatusUnauthorized, "unauthorized")
	e.do(http.MethodGet, "/api/v1/me", nil, bearer(second)).wantStatus(t, http.StatusOK)

	web := e.webCookie("vlad")
	r = e.do(http.MethodPost, "/api/v1/auth/logout", nil, cookie(web), header("Origin", testPublicURL))
	r.wantStatus(t, http.StatusNoContent)
	if got := r.header.Get("Set-Cookie"); !strings.Contains(got, "Max-Age=0") {
		t.Errorf("cookie не удалена: %q", got)
	}
}

func TestLogoutAll(t *testing.T) {
	e := newEnv(t)
	_, token := e.register("vlad")
	second := e.login("vlad", testPassword).json(t)["token"].(string)
	_, other := e.register("other")

	e.do(http.MethodPost, "/api/v1/auth/logout-all", nil, bearer(token)).wantStatus(t, http.StatusNoContent)
	e.do(http.MethodGet, "/api/v1/me", nil, bearer(token)).wantProblem(t, http.StatusUnauthorized, "unauthorized")
	e.do(http.MethodGet, "/api/v1/me", nil, bearer(second)).wantProblem(t, http.StatusUnauthorized, "unauthorized")
	e.do(http.MethodGet, "/api/v1/me", nil, bearer(other)).wantStatus(t, http.StatusOK)

	web := e.webCookie("vlad")
	r := e.do(http.MethodPost, "/api/v1/auth/logout-all", nil, cookie(web), header("Origin", testPublicURL))
	r.wantStatus(t, http.StatusNoContent)
	if got := r.header.Get("Set-Cookie"); !strings.Contains(got, "Max-Age=0") {
		t.Errorf("cookie не удалена: %q", got)
	}
}

func TestTelegramLoginAndLink(t *testing.T) {
	e := newEnv(t)
	_, token := e.register("vlad")
	now := time.Now()
	const tgID = 123456789

	// Пока Telegram не привязан, войти нельзя, а регистрации нет.
	e.do(http.MethodPost, "/api/v1/auth/telegram", telegramData(tgID, now)).
		wantProblem(t, http.StatusUnauthorized, "telegram_not_linked")

	r := e.do(http.MethodPut, "/api/v1/me/telegram", telegramData(tgID, now), bearer(token))
	r.wantStatus(t, http.StatusOK)
	telegram := r.json(t)["telegram"].(map[string]any)
	if telegram["id"] != float64(tgID) || telegram["username"] != "vlad_tg" {
		t.Errorf("telegram = %v", telegram)
	}

	r = e.do(http.MethodPost, "/api/v1/auth/telegram", telegramData(tgID, now))
	r.wantStatus(t, http.StatusOK)
	if _, present := r.json(t)["token"]; present {
		t.Errorf("токен в теле веб-сеанса: %s", r.body)
	}
	if got := r.header.Get("Set-Cookie"); !strings.HasPrefix(got, sessionCookieName+"=") {
		t.Errorf("Set-Cookie = %q", got)
	}
	if n := e.count("SELECT count(*) FROM auth_sessions WHERE client = 'web'"); n != 1 {
		t.Errorf("веб-сеансов: %d", n)
	}

	// Повторная привязка того же Telegram к себе не ошибка, к другому пользователю — конфликт.
	e.do(http.MethodPut, "/api/v1/me/telegram", telegramData(tgID, now), bearer(token)).wantStatus(t, http.StatusOK)
	_, other := e.register("other")
	e.do(http.MethodPut, "/api/v1/me/telegram", telegramData(tgID, now), bearer(other)).
		wantProblem(t, http.StatusConflict, "telegram_taken")

	e.do(http.MethodDelete, "/api/v1/me/telegram", nil, bearer(token)).wantStatus(t, http.StatusNoContent)
	if v := e.do(http.MethodGet, "/api/v1/me", nil, bearer(token)).json(t); v["telegram"] != nil {
		t.Errorf("telegram после отвязки = %v", v["telegram"])
	}
	e.do(http.MethodPost, "/api/v1/auth/telegram", telegramData(tgID, now)).
		wantProblem(t, http.StatusUnauthorized, "telegram_not_linked")
}

func TestTelegramInvalidData(t *testing.T) {
	e := newEnv(t)
	_, token := e.register("vlad")
	now := time.Now()

	forged := telegramData(1, now)
	forged["id"] = 2
	cases := map[string]map[string]any{
		"подделанное поле": forged,
		"устаревшие":       telegramData(1, now.Add(-25*time.Hour)),
	}
	for name, data := range cases {
		t.Run(name, func(t *testing.T) {
			e.do(http.MethodPost, "/api/v1/auth/telegram", data).wantProblem(t, http.StatusUnauthorized, "telegram_auth_invalid")
			e.do(http.MethodPut, "/api/v1/me/telegram", data, bearer(token)).wantProblem(t, http.StatusUnauthorized, "telegram_auth_invalid")
		})
	}

	missing := telegramData(1, now)
	delete(missing, "hash")
	r := e.do(http.MethodPut, "/api/v1/me/telegram", missing, bearer(token))
	r.wantProblem(t, http.StatusBadRequest, "validation_error")
}

func TestTelegramWithoutBotToken(t *testing.T) {
	e := newEnv(t, func(cfg *config.Config) { cfg.TelegramBotToken = "" })
	e.do(http.MethodPost, "/api/v1/auth/telegram", telegramData(1, time.Now())).
		wantProblem(t, http.StatusUnauthorized, "telegram_auth_invalid")
}

func TestUpdateNickname(t *testing.T) {
	e := newEnv(t)
	_, token := e.register("vlad")
	e.register("taken")

	r := e.do(http.MethodPatch, "/api/v1/me", map[string]string{"nickname": "vladislav"}, bearer(token))
	r.wantStatus(t, http.StatusOK)
	if got := r.json(t)["nickname"]; got != "vladislav" {
		t.Errorf("nickname = %v", got)
	}
	e.login("vladislav", testPassword).wantStatus(t, http.StatusOK)

	// Смена регистра своего ника — не конфликт.
	e.do(http.MethodPatch, "/api/v1/me", map[string]string{"nickname": "VLADISLAV"}, bearer(token)).wantStatus(t, http.StatusOK)

	e.do(http.MethodPatch, "/api/v1/me", map[string]string{"nickname": "TAKEN"}, bearer(token)).
		wantProblem(t, http.StatusConflict, "nickname_taken")
	e.do(http.MethodPatch, "/api/v1/me", map[string]string{"nickname": "!"}, bearer(token)).
		wantProblem(t, http.StatusBadRequest, "validation_error")
}

func TestChangePassword(t *testing.T) {
	e := newEnv(t)
	_, token := e.register("vlad")
	second := e.login("vlad", testPassword).json(t)["token"].(string)
	const newPassword = "new-correct-horse"
	change := func(current, next string) response {
		return e.do(http.MethodPut, "/api/v1/me/password",
			map[string]string{"current_password": current, "new_password": next}, bearer(token))
	}

	change("wrong-password", newPassword).wantProblem(t, http.StatusBadRequest, "wrong_password")
	change("x", newPassword).wantProblem(t, http.StatusBadRequest, "wrong_password")
	change(testPassword, "short").wantProblem(t, http.StatusBadRequest, "validation_error")
	e.do(http.MethodGet, "/api/v1/me", nil, bearer(second)).wantStatus(t, http.StatusOK)

	change(testPassword, newPassword).wantStatus(t, http.StatusNoContent)

	// Текущий сеанс остаётся, остальные завершены.
	e.do(http.MethodGet, "/api/v1/me", nil, bearer(token)).wantStatus(t, http.StatusOK)
	e.do(http.MethodGet, "/api/v1/me", nil, bearer(second)).wantProblem(t, http.StatusUnauthorized, "unauthorized")
	e.login("vlad", testPassword).wantProblem(t, http.StatusUnauthorized, "invalid_credentials")
	e.login("vlad", newPassword).wantStatus(t, http.StatusOK)
}

func TestDeleteMe(t *testing.T) {
	e := newEnv(t)
	id, token := e.register("vlad")
	e.do(http.MethodPut, "/api/v1/me/telegram", telegramData(1, time.Now()), bearer(token)).wantStatus(t, http.StatusOK)

	// Своя команда без других участников удаляется вместе с личным пространством.
	teamID := uuid.New()
	e.exec("INSERT INTO teams (id, name) VALUES ($1, 'solo')", teamID)
	e.exec("INSERT INTO team_members (team_id, user_id, role) VALUES ($1, $2, 'owner')", teamID, id)

	r := e.do(http.MethodDelete, "/api/v1/me", nil, bearer(token))
	r.wantStatus(t, http.StatusNoContent)
	if got := r.header.Get("Set-Cookie"); got != "" {
		t.Errorf("Set-Cookie для приложения: %q", got)
	}

	if n := e.count(`SELECT count(*) FROM users WHERE id = $1 AND deleted_at IS NOT NULL
		AND password_hash IS NULL AND telegram_id IS NULL AND telegram_username IS NULL`, id); n != 1 {
		t.Error("учётная запись не обезличена")
	}
	if n := e.count("SELECT count(*) FROM auth_sessions WHERE user_id = $1", id); n != 0 {
		t.Errorf("осталось сеансов: %d", n)
	}
	if n := e.count("SELECT count(*) FROM teams"); n != 0 {
		t.Errorf("осталось команд: %d", n)
	}

	e.do(http.MethodGet, "/api/v1/me", nil, bearer(token)).wantProblem(t, http.StatusUnauthorized, "unauthorized")
	e.login("vlad", testPassword).wantProblem(t, http.StatusUnauthorized, "invalid_credentials")
	e.do(http.MethodPost, "/api/v1/auth/telegram", telegramData(1, time.Now())).
		wantProblem(t, http.StatusUnauthorized, "telegram_not_linked")

	// Ник и Telegram свободны.
	_, again := e.register("vlad")
	e.do(http.MethodPut, "/api/v1/me/telegram", telegramData(1, time.Now()), bearer(again)).wantStatus(t, http.StatusOK)
}

func TestDeleteMeWebClearsCookie(t *testing.T) {
	e := newEnv(t)
	e.register("vlad")
	web := e.webCookie("vlad")
	r := e.do(http.MethodDelete, "/api/v1/me", nil, cookie(web), header("Origin", testPublicURL))
	r.wantStatus(t, http.StatusNoContent)
	if got := r.header.Get("Set-Cookie"); !strings.Contains(got, "Max-Age=0") {
		t.Errorf("cookie не удалена: %q", got)
	}
}

func TestDeleteMeOwnerWithMembers(t *testing.T) {
	e := newEnv(t)
	owner, token := e.register("owner")
	member, _ := e.register("member")
	teamID := uuid.New()
	e.exec("INSERT INTO teams (id, name) VALUES ($1, 'studio')", teamID)
	e.exec("INSERT INTO team_members (team_id, user_id, role) VALUES ($1, $2, 'owner'), ($1, $3, 'member')", teamID, owner, member)

	e.do(http.MethodDelete, "/api/v1/me", nil, bearer(token)).wantProblem(t, http.StatusConflict, "owner_with_members")
	e.do(http.MethodGet, "/api/v1/me", nil, bearer(token)).wantStatus(t, http.StatusOK)

	// Удалённая команда владельца не мешает: восстановить её будет некому.
	e.exec("UPDATE teams SET deleted_at = now() WHERE id = $1", teamID)
	e.do(http.MethodDelete, "/api/v1/me", nil, bearer(token)).wantStatus(t, http.StatusNoContent)
	if n := e.count("SELECT count(*) FROM teams WHERE id = $1", teamID); n != 0 {
		t.Errorf("команда осталась")
	}
}

func TestDeleteMeLeavesTeams(t *testing.T) {
	e := newEnv(t)
	owner, _ := e.register("owner")
	member, token := e.register("member")
	teamID := uuid.New()
	e.exec("INSERT INTO teams (id, name, change_seq) VALUES ($1, 'studio', 5)", teamID)
	e.exec("INSERT INTO team_members (team_id, user_id, role) VALUES ($1, $2, 'owner'), ($1, $3, 'member')", teamID, owner, member)

	addCable := func(assignee *uuid.UUID) uuid.UUID {
		id := uuid.New()
		e.exec(`INSERT INTO cables (id, team_id, name, cable_type, color, assignee_id, created_by, created_at, change_seq)
			VALUES ($1, $2, 'c', 'xlr', 'ff0000', $3, $4, now(), 1)`, id, teamID, assignee, member)
		return id
	}
	assigned1, assigned2 := addCable(&member), addCable(&member)
	untouched := addCable(&owner)
	testID := uuid.New()
	e.exec(`INSERT INTO tests (id, cable_id, author_id, measured_at, device_id, pv, app_version, rules_version,
		health_incomplete, results, payload_hash, change_seq)
		VALUES ($1, $2, $3, now(), 'd', 1, '1', '1', false, '{}', '\x00', 1)`, testID, untouched, member)

	e.do(http.MethodDelete, "/api/v1/me", nil, bearer(token)).wantStatus(t, http.StatusNoContent)

	if n := e.count("SELECT count(*) FROM team_members WHERE team_id = $1 AND user_id = $2", teamID, member); n != 0 {
		t.Error("участник не удалён из команды")
	}
	// Правка каждого кабеля получает свой номер из счётчика команды, версия растёт.
	if n := e.count(`SELECT count(*) FROM cables WHERE id = ANY($1) AND assignee_id IS NULL
		AND version = 2 AND change_seq IN (6, 7)`, []uuid.UUID{assigned1, assigned2}); n != 2 {
		t.Errorf("кабелей со сброшенным ответственным: %d", n)
	}
	if n := e.count("SELECT count(DISTINCT change_seq) FROM cables WHERE id = ANY($1)", []uuid.UUID{assigned1, assigned2}); n != 2 {
		t.Errorf("различных change_seq: %d", n)
	}
	if n := e.count("SELECT count(*) FROM teams WHERE id = $1 AND change_seq = 7", teamID); n != 1 {
		t.Error("счётчик команды не увеличен")
	}
	if n := e.count("SELECT count(*) FROM cables WHERE id = $1 AND assignee_id = $2 AND version = 1", untouched, owner); n != 1 {
		t.Error("чужой кабель изменён")
	}
	if n := e.count("SELECT count(*) FROM audit_events WHERE team_id = $1 AND event = 'cable.assignee_changed' AND subject_user_id = $2", teamID, member); n != 2 {
		t.Errorf("записей cable.assignee_changed: %d", n)
	}
	if n := e.count("SELECT count(*) FROM audit_events WHERE team_id = $1 AND event = 'member.left' AND subject_user_id = $2", teamID, member); n != 1 {
		t.Errorf("записей member.left: %d", n)
	}
	// Тест остаётся с прежним автором.
	if n := e.count("SELECT count(*) FROM tests WHERE id = $1 AND author_id = $2", testID, member); n != 1 {
		t.Error("тест потерян")
	}
}

func TestAppVersion(t *testing.T) {
	e := newEnv(t, func(cfg *config.Config) { cfg.MinAppVersion = "0.7.0" })
	e.register("vlad")

	login := func(opts ...requestOption) response {
		return e.do(http.MethodPost, "/api/v1/auth/login",
			map[string]string{"nickname": "vlad", "password": testPassword, "client": "app"}, opts...)
	}
	r := login(header("X-App-Version", "0.6.9"))
	r.wantProblem(t, http.StatusUpgradeRequired, "app_outdated")
	if got := r.json(t)["min_app_version"]; got != "0.7.0" {
		t.Errorf("min_app_version = %v", got)
	}
	login(header("X-App-Version", "0.7.0")).wantStatus(t, http.StatusOK)
	login(header("X-App-Version", "0.10.0")).wantStatus(t, http.StatusOK)
	login().wantStatus(t, http.StatusOK) // веб не проверяется
}

func TestVersionLess(t *testing.T) {
	tests := []struct {
		version, minimum string
		want             bool
	}{
		{"0.6.9", "0.7.0", true},
		{"0.7.0", "0.7.0", false},
		{"0.10.0", "0.7.0", false},
		{"1", "0.7.0", false},
		{"0.7", "0.7.0", false},
		{"0.7.0+12", "0.7.0", false},
		{"0.6.0-beta", "0.7.0", true},
		{"latest", "0.7.0", true},
		{"1.2.3.4", "0.7.0", true},
		{"-1.0.0", "0.7.0", true},
	}
	for _, tt := range tests {
		if got := versionLess(tt.version, tt.minimum); got != tt.want {
			t.Errorf("versionLess(%q, %q) = %v", tt.version, tt.minimum, got)
		}
	}
}

func TestRateLimiterWindows(t *testing.T) {
	l := newRateLimiter(2, time.Minute)
	start := time.Unix(1_800_000_000, 0)

	for i := range 2 {
		if _, ok := l.allow("a", start); !ok {
			t.Fatalf("попытка %d отклонена", i)
		}
	}
	retry, ok := l.allow("a", start.Add(30*time.Second))
	if ok || retry != 31 {
		t.Errorf("превышение: ok=%v, retry=%d", ok, retry)
	}
	if _, ok := l.allow("b", start); !ok {
		t.Error("другой IP отклонён")
	}
	if _, ok := l.allow("a", start.Add(time.Minute)); !ok {
		t.Error("новое окно отклонено")
	}
	if _, present := l.attempts["b"]; present {
		t.Error("устаревшая запись не удалена")
	}
}
