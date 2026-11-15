package server

import (
	"io"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"testing"

	"github.com/gin-gonic/gin"

	"git.hakoniwa.ru/tech/himodameshi/hub/internal/config"
)

func TestServeStatic(t *testing.T) {
	gin.SetMode(gin.TestMode)

	// Снаружи STATIC_DIR — файл, до которого нельзя добраться через "..".
	parent := t.TempDir()
	if err := os.WriteFile(filepath.Join(parent, "secret.txt"), []byte("secret"), 0o600); err != nil {
		t.Fatal(err)
	}
	dir := filepath.Join(parent, "static")
	files := map[string]string{
		"index.html":                "index",
		"logo.png":                  "logo",
		"_app/immutable/app.abc.js": "app",
	}
	for name, body := range files {
		path := filepath.Join(dir, filepath.FromSlash(name))
		if err := os.MkdirAll(filepath.Dir(path), 0o755); err != nil {
			t.Fatal(err)
		}
		if err := os.WriteFile(path, []byte(body), 0o600); err != nil {
			t.Fatal(err)
		}
	}

	s := New(pingOnlyDB{}, config.Config{StaticDir: dir}, slog.New(slog.NewJSONHandler(io.Discard, nil)))
	handler, err := s.Handler()
	if err != nil {
		t.Fatal(err)
	}

	tests := []struct {
		name      string
		method    string
		path      string
		wantCode  int
		wantBody  string
		wantCache string
	}{
		{name: "файл", method: http.MethodGet, path: "/logo.png", wantCode: http.StatusOK, wantBody: "logo"},
		{
			name: "файл сборки с хешем", method: http.MethodGet, path: "/_app/immutable/app.abc.js",
			wantCode: http.StatusOK, wantBody: "app", wantCache: "public, max-age=31536000, immutable",
		},
		{name: "корень", method: http.MethodGet, path: "/", wantCode: http.StatusOK, wantBody: "index", wantCache: "no-cache"},
		{name: "маршрут SPA", method: http.MethodGet, path: "/teams/cables/42", wantCode: http.StatusOK, wantBody: "index", wantCache: "no-cache"},
		{name: "каталог", method: http.MethodGet, path: "/_app/immutable", wantCode: http.StatusOK, wantBody: "index", wantCache: "no-cache"},
		// path.Clean не выпускает за STATIC_DIR, а http.ServeFile ещё и отклоняет пути с "..".
		{name: "выход за каталог", method: http.MethodGet, path: "/../secret.txt", wantCode: http.StatusBadRequest},
		{name: "неизвестный путь API", method: http.MethodGet, path: "/api/v1/nope", wantCode: http.StatusNotFound},
		{name: "не GET", method: http.MethodPost, path: "/teams", wantCode: http.StatusNotFound},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			rec := httptest.NewRecorder()
			handler.ServeHTTP(rec, httptest.NewRequest(tt.method, tt.path, nil))

			if rec.Code != tt.wantCode {
				t.Fatalf("код ответа = %d, ожидался %d", rec.Code, tt.wantCode)
			}
			if rec.Body.String() == "secret" {
				t.Fatal("отдан файл вне STATIC_DIR")
			}
			if tt.wantBody != "" && rec.Body.String() != tt.wantBody {
				t.Errorf("тело ответа = %q, ожидалось %q", rec.Body.String(), tt.wantBody)
			}
			if got := rec.Header().Get("Cache-Control"); got != tt.wantCache {
				t.Errorf("Cache-Control = %q, ожидалось %q", got, tt.wantCache)
			}
		})
	}
}

func TestNoStaticDir(t *testing.T) {
	gin.SetMode(gin.TestMode)

	s := New(pingOnlyDB{}, config.Config{}, slog.New(slog.NewJSONHandler(io.Discard, nil)))
	handler, err := s.Handler()
	if err != nil {
		t.Fatal(err)
	}
	rec := httptest.NewRecorder()
	handler.ServeHTTP(rec, httptest.NewRequest(http.MethodGet, "/teams", nil))

	if rec.Code != http.StatusNotFound {
		t.Errorf("код ответа = %d, ожидался 404", rec.Code)
	}
}
