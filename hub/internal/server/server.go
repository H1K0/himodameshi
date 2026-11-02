// Package server реализует HTTP API Himo Hub.
package server

import (
	"context"
	"log/slog"
	"net/http"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/jackc/pgx/v5"

	"git.hakoniwa.ru/tech/himodameshi/hub/internal/api"
	"git.hakoniwa.ru/tech/himodameshi/hub/internal/config"
	"git.hakoniwa.ru/tech/himodameshi/hub/internal/store"
)

const defaultPingTimeout = 2 * time.Second

// Pinger проверяет соединение с БД.
type Pinger interface {
	Ping(ctx context.Context) error
}

// DB — то, что сервер использует от пула соединений.
type DB interface {
	Pinger
	store.DBTX
	Begin(ctx context.Context) (pgx.Tx, error)
}

type Server struct {
	db          DB
	q           *store.Queries
	cfg         config.Config
	publicURL   string
	log         *slog.Logger
	pingTimeout time.Duration
	limiter     *rateLimiter
	now         func() time.Time
}

func New(db DB, cfg config.Config, log *slog.Logger) *Server {
	return &Server{
		db:          db,
		q:           store.New(db),
		cfg:         cfg,
		publicURL:   strings.TrimRight(cfg.PublicURL, "/"),
		log:         log,
		pingTimeout: defaultPingTimeout,
		limiter:     newRateLimiter(authAttemptsLimit, authAttemptsPeriod),
		now:         time.Now,
	}
}

// Handler возвращает маршруты API.
func (s *Server) Handler() (http.Handler, error) {
	r := gin.New()
	// Обработчики получают *gin.Context как context.Context; без этого он не отменяется с запросом.
	r.ContextWithFallback = true
	if err := r.SetTrustedProxies(s.cfg.TrustedProxies); err != nil {
		return nil, err
	}
	r.Use(gin.Recovery(), s.handleErrors, s.checkAppVersion)

	strict := api.NewStrictHandler(s, []api.StrictMiddlewareFunc{s.limitAuthAttempts})
	api.RegisterHandlersWithOptions(r, strict, api.GinServerOptions{
		Middlewares: []api.MiddlewareFunc{s.authenticate},
		// Параметры адреса разбирает сгенерированный код; без этого ошибка уйдёт не в формате RFC 9457.
		ErrorHandler: func(c *gin.Context, _ error, _ int) {
			abortWithProblem(c, validationError(api.FieldError{Field: "params", Message: "некорректное значение параметра"}))
		},
	})
	return r, nil
}

// Health отвечает 200, если БД доступна, и 503, если нет.
func (s *Server) Health(ctx context.Context, _ api.HealthRequestObject) (api.HealthResponseObject, error) {
	ctx, cancel := context.WithTimeout(ctx, s.pingTimeout)
	defer cancel()

	if err := s.db.Ping(ctx); err != nil {
		s.log.ErrorContext(ctx, "database is unavailable", "error", err)
		return api.Health503JSONResponse{Status: api.Unavailable}, nil
	}
	return api.Health200JSONResponse{Status: api.Ok}, nil
}
