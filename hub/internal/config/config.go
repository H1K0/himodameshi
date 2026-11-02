// Package config загружает конфигурацию сервера из переменных окружения.
package config

import (
	"encoding/json"
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
	// Plans — лимиты тарифов по ключу из teams.plan (HUB-3).
	Plans Plans `env:"PLANS" envDefault:"{\"free\":{\"max_members\":5}}"`
}

// FreePlan — тариф по умолчанию; его лимиты применяются и к неизвестному ключу.
const FreePlan = "free"

type Plan struct {
	MaxMembers int `json:"max_members"`
}

type Plans map[string]Plan

func (p *Plans) UnmarshalText(text []byte) error {
	// Через обычную карту: у Plans есть UnmarshalText, и json ждал бы строку, а не объект.
	var plans map[string]Plan
	if err := json.Unmarshal(text, &plans); err != nil {
		return err
	}
	*p = plans
	return nil
}

func Load() (Config, error) {
	cfg, err := env.ParseAs[Config]()
	if err != nil {
		return Config{}, err
	}
	if _, ok := cfg.Plans[FreePlan]; !ok {
		return Config{}, fmt.Errorf("PLANS: no %q plan", FreePlan)
	}
	if cfg.MinAppVersion != "" && !versionRe.MatchString(cfg.MinAppVersion) {
		return Config{}, fmt.Errorf("MIN_APP_VERSION: invalid version %q", cfg.MinAppVersion)
	}
	return cfg, nil
}
