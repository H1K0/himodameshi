// Команда hub запускает сервер Himo Hub; hub healthcheck проверяет запущенный сервер.
package main

import (
	"context"
	"errors"
	"fmt"
	"log/slog"
	"net"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/jackc/pgx/v5/pgxpool"

	"git.hakoniwa.ru/tech/himodameshi/hub/internal/config"
	"git.hakoniwa.ru/tech/himodameshi/hub/internal/migrations"
	"git.hakoniwa.ru/tech/himodameshi/hub/internal/server"
)

const (
	shutdownTimeout    = 10 * time.Second
	healthcheckTimeout = 3 * time.Second
)

func main() {
	// В образе distroless нет curl, поэтому healthcheck контейнера — подкоманда сервера (ADR-015).
	if len(os.Args) > 1 && os.Args[1] == "healthcheck" {
		if err := healthcheck(); err != nil {
			fmt.Fprintln(os.Stderr, err)
			os.Exit(1)
		}
		return
	}

	log := slog.New(slog.NewJSONHandler(os.Stdout, nil))
	if err := run(log); err != nil {
		log.Error("server stopped", "error", err)
		os.Exit(1)
	}
}

func run(log *slog.Logger) error {
	cfg, err := config.Load()
	if err != nil {
		return err
	}

	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stop()

	db, err := pgxpool.New(ctx, cfg.DatabaseURL)
	if err != nil {
		return err
	}
	defer db.Close()

	// Миграции применяются при старте (ADR-015), поэтому без БД сервер не запускается.
	// Если БД пропадёт позже, /health ответит 503.
	if err := migrations.Up(ctx, db); err != nil {
		return err
	}

	gin.SetMode(gin.ReleaseMode)
	handler, err := server.New(db, cfg, log).Handler()
	if err != nil {
		return err
	}
	srv := &http.Server{
		Addr:              cfg.Addr,
		Handler:           handler,
		ReadHeaderTimeout: 5 * time.Second,
	}

	errc := make(chan error, 1)
	go func() {
		log.Info("server started", "addr", cfg.Addr)
		errc <- srv.ListenAndServe()
	}()

	select {
	case err := <-errc:
		return err
	case <-ctx.Done():
	}

	shutdownCtx, cancel := context.WithTimeout(context.Background(), shutdownTimeout)
	defer cancel()
	if err := srv.Shutdown(shutdownCtx); err != nil && !errors.Is(err, http.ErrServerClosed) {
		return err
	}
	return nil
}

// healthcheck запрашивает GET /health у сервера в том же контейнере.
func healthcheck() error {
	cfg, err := config.Load()
	if err != nil {
		return err
	}
	host, port, err := net.SplitHostPort(cfg.Addr)
	if err != nil {
		return err
	}
	if host == "" || host == "0.0.0.0" || host == "::" {
		host = "127.0.0.1"
	}

	client := &http.Client{Timeout: healthcheckTimeout}
	resp, err := client.Get("http://" + net.JoinHostPort(host, port) + "/health")
	if err != nil {
		return err
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("health: status %d", resp.StatusCode)
	}
	return nil
}
