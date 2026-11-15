package server

import (
	"net/http"
	"os"
	"path"
	"path/filepath"
	"strings"

	"github.com/gin-gonic/gin"
)

// serveStatic отдаёт собранный веб из STATIC_DIR (ADR-015). Существующий файл отдаётся как есть,
// любой другой путь вне /api — index.html: маршрут разбирает роутер SPA в браузере.
func (s *Server) serveStatic(c *gin.Context) {
	urlPath := c.Request.URL.Path
	if urlPath == "/api" || strings.HasPrefix(urlPath, "/api/") ||
		(c.Request.Method != http.MethodGet && c.Request.Method != http.MethodHead) {
		abortWithProblem(c, errNotFound)
		return
	}

	// path.Clean от пути с ведущим "/" убирает "..", поэтому выйти за STATIC_DIR нельзя.
	name := filepath.Join(s.cfg.StaticDir, filepath.FromSlash(path.Clean("/"+urlPath)))
	if info, err := os.Stat(name); err == nil && !info.IsDir() {
		// Имена файлов в _app/immutable содержат хеш содержимого и после деплоя не меняются.
		if strings.HasPrefix(urlPath, "/_app/immutable/") {
			c.Header("Cache-Control", "public, max-age=31536000, immutable")
		}
		c.File(name)
		return
	}

	// index.html ссылается на файлы текущей сборки, поэтому браузер перепроверяет его при каждом заходе.
	c.Header("Cache-Control", "no-cache")
	c.File(filepath.Join(s.cfg.StaticDir, "index.html"))
}
