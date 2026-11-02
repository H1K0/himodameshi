package server

import (
	"context"
	"encoding/json"
	"errors"
	"net/http"
	"regexp"
	"strconv"
	"sync"
	"time"
	"unicode/utf8"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgconn"

	"git.hakoniwa.ru/tech/himodameshi/hub/internal/api"
	"git.hakoniwa.ru/tech/himodameshi/hub/internal/auth"
	"git.hakoniwa.ru/tech/himodameshi/hub/internal/store"
)

const (
	personalTeamName = "Личное пространство"

	passwordMinLen = 8
	passwordMaxLen = 128

	uniqueViolation     = "23505"
	nicknameConstraint  = "users_nickname_uq"
	telegramIDConstrain = "users_telegram_id_key"
)

var nicknameRe = regexp.MustCompile(`^[A-Za-z0-9_]{3,32}$`)

// dummyPasswordHash сравнивается при входе с несуществующим ником,
// чтобы такой отказ по времени не отличался от неверного пароля.
var dummyPasswordHash = sync.OnceValues(func() (string, error) {
	return auth.HashPassword("himo-dummy-password")
})

// Register создаёт учётную запись, личное пространство и сеанс.
func (s *Server) Register(ctx context.Context, request api.RegisterRequestObject) (api.RegisterResponseObject, error) {
	body := request.Body
	var fields []api.FieldError
	fields = appendNicknameError(fields, "nickname", body.Nickname)
	fields = appendPasswordError(fields, "password", body.Password)
	fields = appendClientError(fields, body.Client)
	if len(fields) > 0 {
		return nil, validationError(fields...)
	}

	hash, err := auth.HashPassword(body.Password)
	if err != nil {
		return nil, err
	}

	var user store.User
	var resp sessionResponse
	err = pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		q := s.q.WithTx(tx)

		userID, err := uuid.NewV7()
		if err != nil {
			return err
		}
		teamID, err := uuid.NewV7()
		if err != nil {
			return err
		}
		user, err = q.CreateUser(ctx, store.CreateUserParams{ID: userID, Nickname: body.Nickname, PasswordHash: &hash})
		if err != nil {
			return err
		}
		if err := q.CreatePersonalTeam(ctx, store.CreatePersonalTeamParams{ID: teamID, Name: personalTeamName}); err != nil {
			return err
		}
		if err := q.AddTeamOwner(ctx, store.AddTeamOwnerParams{TeamID: teamID, UserID: userID}); err != nil {
			return err
		}
		resp, err = s.openSession(ctx, q, user, body.Client, http.StatusCreated)
		return err
	})
	if isUniqueViolation(err, nicknameConstraint) {
		return nil, errNicknameTaken
	}
	if err != nil {
		return nil, err
	}

	s.logSecurity(ctx, "register", "user_id", user.ID)
	return resp, nil
}

// Login открывает сеанс по нику и паролю.
func (s *Server) Login(ctx context.Context, request api.LoginRequestObject) (api.LoginResponseObject, error) {
	body := request.Body
	var fields []api.FieldError
	if body.Nickname == "" {
		fields = append(fields, api.FieldError{Field: "nickname", Message: "не может быть пустым"})
	}
	fields = appendPasswordError(fields, "password", body.Password)
	fields = appendClientError(fields, body.Client)
	if len(fields) > 0 {
		return nil, validationError(fields...)
	}

	user, err := s.q.GetUserByNickname(ctx, body.Nickname)
	if err != nil && !errors.Is(err, pgx.ErrNoRows) {
		return nil, err
	}
	found := err == nil

	var hash string
	if found && user.PasswordHash != nil {
		hash = *user.PasswordHash
	} else if hash, err = dummyPasswordHash(); err != nil {
		return nil, err
	}
	match, err := auth.VerifyPassword(hash, body.Password)
	if err != nil {
		return nil, err
	}
	if !found || !match {
		s.logSecurity(ctx, "login_failed", "nickname", body.Nickname)
		return nil, errInvalidCredentials
	}

	resp, err := s.openSession(ctx, s.q, user, body.Client, http.StatusOK)
	if err != nil {
		return nil, err
	}
	s.logSecurity(ctx, "login", "user_id", user.ID, "client", body.Client)
	return resp, nil
}

// LoginTelegram открывает веб-сеанс по данным Telegram Login Widget.
func (s *Server) LoginTelegram(ctx context.Context, request api.LoginTelegramRequestObject) (api.LoginTelegramResponseObject, error) {
	if err := s.checkTelegram(ctx, request.Body); err != nil {
		return nil, err
	}

	user, err := s.q.GetUserByTelegramID(ctx, &request.Body.Id)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, errTelegramNotLinked
	}
	if err != nil {
		return nil, err
	}

	resp, err := s.openSession(ctx, s.q, user, api.Web, http.StatusOK)
	if err != nil {
		return nil, err
	}
	s.logSecurity(ctx, "login", "user_id", user.ID, "client", api.Web, "method", "telegram")
	return resp, nil
}

// Logout завершает текущий сеанс.
func (s *Server) Logout(ctx context.Context, _ api.LogoutRequestObject) (api.LogoutResponseObject, error) {
	session := sessionFrom(ctx)
	if err := s.q.RevokeSession(ctx, session.id); err != nil {
		return nil, err
	}
	s.logSecurity(ctx, "logout", "user_id", session.user.ID)
	return noContentResponse{clearCookie: session.viaCookie}, nil
}

// LogoutAll завершает все сеансы пользователя, включая текущий.
func (s *Server) LogoutAll(ctx context.Context, _ api.LogoutAllRequestObject) (api.LogoutAllResponseObject, error) {
	session := sessionFrom(ctx)
	if err := s.q.RevokeUserSessions(ctx, session.user.ID); err != nil {
		return nil, err
	}
	s.logSecurity(ctx, "logout_all", "user_id", session.user.ID)
	return noContentResponse{clearCookie: session.viaCookie}, nil
}

// openSession создаёт сеанс: для веба токен уходит в cookie, для приложения — в тело ответа.
func (s *Server) openSession(ctx context.Context, q *store.Queries, user store.User, client api.ClientType, status int) (sessionResponse, error) {
	token, err := auth.NewToken()
	if err != nil {
		return sessionResponse{}, err
	}
	expiresAt := s.now().Add(sessionTTL)
	err = q.CreateSession(ctx, store.CreateSessionParams{
		UserID:    user.ID,
		TokenHash: auth.HashToken(token),
		Client:    string(client),
		ExpiresAt: expiresAt,
	})
	if err != nil {
		return sessionResponse{}, err
	}

	resp := sessionResponse{status: status, body: api.Session{User: toAPIUser(user), ExpiresAt: expiresAt.UTC()}}
	if client == api.Web {
		resp.cookie = sessionCookie(token, int(sessionTTL.Seconds()))
	} else {
		resp.body.Token = &token
	}
	return resp, nil
}

// checkTelegram проверяет данные виджета; их подпись охватывает все поля, кроме hash.
func (s *Server) checkTelegram(ctx context.Context, data *api.TelegramAuthData) error {
	var missing []api.FieldError
	for field, empty := range map[string]bool{
		"id":         data.Id == 0,
		"first_name": data.FirstName == "",
		"auth_date":  data.AuthDate == 0,
		"hash":       data.Hash == "",
	} {
		if empty {
			missing = append(missing, api.FieldError{Field: field, Message: "обязательное поле"})
		}
	}
	if len(missing) > 0 {
		return validationError(missing...)
	}

	fields := map[string]string{
		"id":         strconv.FormatInt(data.Id, 10),
		"first_name": data.FirstName,
		"auth_date":  strconv.FormatInt(data.AuthDate, 10),
	}
	for name, value := range map[string]*string{
		"last_name": data.LastName,
		"username":  data.Username,
		"photo_url": data.PhotoUrl,
	} {
		if value != nil {
			fields[name] = *value
		}
	}
	if !auth.VerifyTelegram(s.cfg.TelegramBotToken, fields, data.Hash, time.Unix(data.AuthDate, 0), s.now()) {
		s.logSecurity(ctx, "telegram_auth_failed")
		return errTelegramAuthInvalid
	}
	return nil
}

func sessionFrom(ctx context.Context) *currentSession {
	session, _ := ctx.Value(currentSessionKey).(*currentSession)
	return session
}

func toAPIUser(user store.User) api.User {
	result := api.User{Id: user.ID, Nickname: user.Nickname, CreatedAt: user.CreatedAt.UTC()}
	if user.TelegramID != nil {
		result.Telegram = &api.TelegramAccount{Id: *user.TelegramID, Username: user.TelegramUsername}
	}
	return result
}

func appendNicknameError(fields []api.FieldError, name, nickname string) []api.FieldError {
	if !nicknameRe.MatchString(nickname) {
		return append(fields, api.FieldError{Field: name, Message: "от 3 до 32 символов: латинские буквы, цифры и _"})
	}
	return fields
}

func appendPasswordError(fields []api.FieldError, name, password string) []api.FieldError {
	if !validPasswordLength(password) {
		return append(fields, api.FieldError{Field: name, Message: "от 8 до 128 символов"})
	}
	return fields
}

func validPasswordLength(password string) bool {
	n := utf8.RuneCountInString(password)
	return n >= passwordMinLen && n <= passwordMaxLen
}

func appendClientError(fields []api.FieldError, client api.ClientType) []api.FieldError {
	if client != api.Web && client != api.App {
		return append(fields, api.FieldError{Field: "client", Message: "ожидается web или app"})
	}
	return fields
}

func isUniqueViolation(err error, constraint string) bool {
	var pgErr *pgconn.PgError
	return errors.As(err, &pgErr) && pgErr.Code == uniqueViolation && pgErr.ConstraintName == constraint
}

// logSecurity пишет событие безопасности в журнал (ADR-022). Без паролей и токенов.
func (s *Server) logSecurity(ctx context.Context, event string, args ...any) {
	args = append([]any{"event", event}, args...)
	if c, ok := ctx.(*gin.Context); ok {
		args = append(args, "ip", c.ClientIP())
	}
	s.log.InfoContext(ctx, "security event", args...)
}

// sessionResponse — ответ с сеансом. Сгенерированный ответ всегда ставит заголовок Set-Cookie,
// даже пустой, а для приложения его быть не должно.
type sessionResponse struct {
	status int
	body   api.Session
	cookie string
}

func (r sessionResponse) visit(w http.ResponseWriter) error {
	if r.cookie != "" {
		w.Header().Set("Set-Cookie", r.cookie)
	}
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(r.status)
	return json.NewEncoder(w).Encode(r.body)
}

func (r sessionResponse) VisitRegisterResponse(w http.ResponseWriter) error { return r.visit(w) }
func (r sessionResponse) VisitLoginResponse(w http.ResponseWriter) error    { return r.visit(w) }
func (r sessionResponse) VisitLoginTelegramResponse(w http.ResponseWriter) error {
	return r.visit(w)
}

// noContentResponse — ответ 204, при необходимости удаляющий веб-cookie.
type noContentResponse struct {
	clearCookie bool
}

func (r noContentResponse) visit(w http.ResponseWriter) error {
	if r.clearCookie {
		w.Header().Set("Set-Cookie", sessionCookie("", -1))
	}
	w.WriteHeader(http.StatusNoContent)
	return nil
}

func (r noContentResponse) VisitLogoutResponse(w http.ResponseWriter) error    { return r.visit(w) }
func (r noContentResponse) VisitLogoutAllResponse(w http.ResponseWriter) error { return r.visit(w) }
func (r noContentResponse) VisitDeleteMeResponse(w http.ResponseWriter) error  { return r.visit(w) }
