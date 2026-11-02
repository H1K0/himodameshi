// Package config загружает конфигурацию сервера из переменных окружения.
package config

import "github.com/caarlos0/env/v11"

type Config struct {
	DatabaseURL string `env:"DATABASE_URL,required,notEmpty"`
	Addr        string `env:"HUB_ADDR" envDefault:":8080"`
}

func Load() (Config, error) {
	return env.ParseAs[Config]()
}
