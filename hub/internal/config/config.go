// Package config загружает конфигурацию сервера из переменных окружения.
package config

import (
	"fmt"
	"regexp"

	"github.com/caarlos0/env/v11"
)

var versionRe = regexp.MustCompile(`^\d+(\.\d+){0,2}$`)

type Config struct {
	DatabaseURL string `env:"DATABASE_URL,required,notEmpty"`
	Addr        string `env:"HUB_ADDR" envDefault:":8080"`
	// PublicURL — адрес сервиса; с ним сравнивается заголовок Origin (ADR-022).
	PublicURL string `env:"PUBLIC_URL,required,notEmpty"`
	// TelegramBotToken — токен бота Login Widget; без него вход и привязка Telegram отклоняются.
	TelegramBotToken string `env:"TELEGRAM_BOT_TOKEN"`
	// MinAppVersion — минимальная версия приложения; пустая значит «без проверки».
	MinAppVersion string `env:"MIN_APP_VERSION"`
	// TrustedProxies — адреса, от которых принимается X-Forwarded-For (ADR-017).
	TrustedProxies []string `env:"TRUSTED_PROXIES" envSeparator:","`
}

func Load() (Config, error) {
	cfg, err := env.ParseAs[Config]()
	if err != nil {
		return Config{}, err
	}
	if cfg.MinAppVersion != "" && !versionRe.MatchString(cfg.MinAppVersion) {
		return Config{}, fmt.Errorf("MIN_APP_VERSION: invalid version %q", cfg.MinAppVersion)
	}
	return cfg, nil
}
