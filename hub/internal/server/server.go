// Package server реализует HTTP API Himo Hub.
package server

import (
	"context"
	"log/slog"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"

	"git.hakoniwa.ru/tech/himodameshi/hub/internal/api"
)

const defaultPingTimeout = 2 * time.Second

// Pinger проверяет соединение с БД.
type Pinger interface {
	Ping(ctx context.Context) error
}

type Server struct {
	db          Pinger
	log         *slog.Logger
	pingTimeout time.Duration
}

func New(db Pinger, log *slog.Logger) *Server {
	return &Server{db: db, log: log, pingTimeout: defaultPingTimeout}
}

// Handler возвращает маршруты API.
func (s *Server) Handler() http.Handler {
	r := gin.New()
	r.Use(gin.Recovery())
	api.RegisterHandlers(r, api.NewStrictHandler(s, nil))
	return r
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
