package server

import (
	"errors"
	"net/http"
	"strconv"
	"strings"
	"sync"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/jackc/pgx/v5"

	"git.hakoniwa.ru/tech/himodameshi/hub/internal/api"
	"git.hakoniwa.ru/tech/himodameshi/hub/internal/auth"
	"git.hakoniwa.ru/tech/himodameshi/hub/internal/store"
)

const (
	sessionCookieName = "__Host-himo_session"
	sessionTTL        = 30 * 24 * time.Hour
	// Срок сеанса продлевается, только если с прошлого продления прошло больше суток.
	sessionExtendAfter = 24 * time.Hour

	authAttemptsLimit  = 10
	authAttemptsPeriod = time.Minute

	currentSessionKey = "himo.session"
)

// currentSession — действующий сеанс запроса.
type currentSession struct {
	id        int64
	user      store.User
	viaCookie bool
}

// authenticate требует сеанс на маршрутах, для которых контракт задаёт security.
func (s *Server) authenticate(c *gin.Context) {
	if _, secured := c.Get(api.BearerAuthScopes); !secured {
		return
	}

	token, viaCookie := sessionToken(c.Request)
	if token == "" {
		abortWithProblem(c, errUnauthorized)
		return
	}
	if viaCookie && isMutating(c.Request.Method) && c.GetHeader("Origin") != s.publicURL {
		abortWithProblem(c, errOriginMismatch)
		return
	}

	row, err := s.q.GetActiveSession(c, auth.HashToken(token))
	if errors.Is(err, pgx.ErrNoRows) {
		abortWithProblem(c, errUnauthorized)
		return
	}
	if err != nil {
		s.log.ErrorContext(c, "session lookup failed", "error", err)
		abortWithProblem(c, errInternal)
		return
	}

	if now := s.now(); row.ExpiresAt.Sub(now) < sessionTTL-sessionExtendAfter {
		if err := s.q.ExtendSession(c, store.ExtendSessionParams{ID: row.ID, ExpiresAt: now.Add(sessionTTL)}); err != nil {
			s.log.ErrorContext(c, "session extension failed", "error", err)
			abortWithProblem(c, errInternal)
			return
		}
		if viaCookie {
			// Иначе cookie истечёт раньше продлённого сеанса.
			c.Header("Set-Cookie", sessionCookie(token, int(sessionTTL.Seconds())))
		}
	}

	c.Set(currentSessionKey, &currentSession{id: row.ID, user: row.User, viaCookie: viaCookie})
}

func abortWithProblem(c *gin.Context, p *problem) {
	writeProblem(c, p)
	c.Abort()
}

// sessionToken берёт токен из заголовка Authorization, а если его нет — из cookie.
func sessionToken(r *http.Request) (token string, viaCookie bool) {
	if header := r.Header.Get("Authorization"); header != "" {
		scheme, value, ok := strings.Cut(header, " ")
		if !ok || !strings.EqualFold(scheme, "Bearer") {
			return "", false
		}
		return value, false
	}
	cookie, err := r.Cookie(sessionCookieName)
	if err != nil {
		return "", false
	}
	return cookie.Value, true
}

func isMutating(method string) bool {
	switch method {
	case http.MethodPost, http.MethodPut, http.MethodPatch, http.MethodDelete:
		return true
	}
	return false
}

func sessionCookie(token string, maxAge int) string {
	cookie := http.Cookie{
		Name:     sessionCookieName,
		Value:    token,
		Path:     "/",
		MaxAge:   maxAge,
		HttpOnly: true,
		Secure:   true,
		SameSite: http.SameSiteStrictMode,
	}
	return cookie.String()
}

// checkAppVersion отклоняет запросы устаревшего приложения; запросы без заголовка (веб) не проверяются.
func (s *Server) checkAppVersion(c *gin.Context) {
	version := c.GetHeader("X-App-Version")
	if version == "" || s.cfg.MinAppVersion == "" || !versionLess(version, s.cfg.MinAppVersion) {
		return
	}
	status := http.StatusUpgradeRequired
	writeProblemBody(c, status, api.AppOutdatedProblem{
		Type:          "about:blank",
		Title:         http.StatusText(status),
		Status:        status,
		Code:          "app_outdated",
		MinAppVersion: s.cfg.MinAppVersion,
	})
	c.Abort()
}

// versionLess сравнивает версии вида X.Y.Z. Неразборчивая версия считается устаревшей.
func versionLess(version, minimum string) bool {
	got, ok := parseVersion(version)
	if !ok {
		return true
	}
	want, _ := parseVersion(minimum)
	for i := range got {
		if got[i] != want[i] {
			return got[i] < want[i]
		}
	}
	return false
}

func parseVersion(version string) (parsed [3]int, ok bool) {
	// Сборка и предрелиз (0.7.0+12, 0.7.0-beta) на сравнение не влияют.
	version, _, _ = strings.Cut(version, "+")
	version, _, _ = strings.Cut(version, "-")
	parts := strings.Split(version, ".")
	if len(parts) > len(parsed) {
		return parsed, false
	}
	for i, part := range parts {
		n, err := strconv.Atoi(part)
		if err != nil || n < 0 {
			return parsed, false
		}
		parsed[i] = n
	}
	return parsed, true
}

// limitAuthAttempts ограничивает частоту входа и регистрации с одного IP (ADR-022).
func (s *Server) limitAuthAttempts(next api.StrictHandlerFunc, operationID string) api.StrictHandlerFunc {
	switch operationID {
	case "Register", "Login", "LoginTelegram":
	default:
		return next
	}
	return func(c *gin.Context, request any) (any, error) {
		if retryAfter, ok := s.limiter.allow(c.ClientIP(), s.now()); !ok {
			s.logSecurity(c, "rate_limited", "operation", operationID)
			return nil, &problem{status: http.StatusTooManyRequests, code: "rate_limited", retryAfter: retryAfter}
		}
		return next(c, request)
	}
}

// rateLimiter — счётчик попыток с фиксированным окном. Сервер работает в одном экземпляре,
// поэтому счётчики хранятся в памяти.
type rateLimiter struct {
	mu       sync.Mutex
	limit    int
	period   time.Duration
	attempts map[string]*attemptWindow
	swept    time.Time
}

type attemptWindow struct {
	start time.Time
	count int
}

func newRateLimiter(limit int, period time.Duration) *rateLimiter {
	return &rateLimiter{limit: limit, period: period, attempts: make(map[string]*attemptWindow)}
}

// allow учитывает попытку; при превышении возвращает, через сколько секунд можно повторить.
func (l *rateLimiter) allow(key string, now time.Time) (retryAfter int, ok bool) {
	l.mu.Lock()
	defer l.mu.Unlock()

	if now.Sub(l.swept) >= l.period {
		for k, w := range l.attempts {
			if now.Sub(w.start) >= l.period {
				delete(l.attempts, k)
			}
		}
		l.swept = now
	}

	w := l.attempts[key]
	if w == nil || now.Sub(w.start) >= l.period {
		l.attempts[key] = &attemptWindow{start: now, count: 1}
		return 0, true
	}
	if w.count >= l.limit {
		return int((l.period - now.Sub(w.start)).Seconds()) + 1, false
	}
	w.count++
	return 0, true
}
