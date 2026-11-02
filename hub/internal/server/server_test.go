package server

import (
	"context"
	"errors"
	"io"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"github.com/gin-gonic/gin"
)

type pingerFunc func(ctx context.Context) error

func (f pingerFunc) Ping(ctx context.Context) error { return f(ctx) }

func TestHealth(t *testing.T) {
	gin.SetMode(gin.TestMode)

	tests := []struct {
		name     string
		ping     pingerFunc
		wantCode int
		wantBody string
	}{
		{
			name:     "БД доступна",
			ping:     func(context.Context) error { return nil },
			wantCode: http.StatusOK,
			wantBody: `{"status":"ok"}`,
		},
		{
			name:     "БД недоступна",
			ping:     func(context.Context) error { return errors.New("connection refused") },
			wantCode: http.StatusServiceUnavailable,
			wantBody: `{"status":"unavailable"}`,
		},
		{
			name: "БД не отвечает",
			ping: func(ctx context.Context) error {
				<-ctx.Done()
				return ctx.Err()
			},
			wantCode: http.StatusServiceUnavailable,
			wantBody: `{"status":"unavailable"}`,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			s := New(tt.ping, slog.New(slog.NewJSONHandler(io.Discard, nil)))
			s.pingTimeout = 10 * time.Millisecond

			rec := httptest.NewRecorder()
			s.Handler().ServeHTTP(rec, httptest.NewRequest(http.MethodGet, "/health", nil))

			if rec.Code != tt.wantCode {
				t.Errorf("код ответа = %d, ожидался %d", rec.Code, tt.wantCode)
			}
			if got := rec.Header().Get("Content-Type"); got != "application/json" {
				t.Errorf("Content-Type = %q", got)
			}
			if got := rec.Body.String(); got != tt.wantBody+"\n" {
				t.Errorf("тело ответа = %q, ожидалось %q", got, tt.wantBody)
			}
		})
	}
}
