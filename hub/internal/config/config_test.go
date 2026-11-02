package config

import "testing"

func TestLoad(t *testing.T) {
	tests := []struct {
		name    string
		min     string
		publicU string
		wantErr bool
	}{
		{name: "минимальный набор", publicU: "https://himo.example"},
		{name: "версия приложения", min: "0.7.0", publicU: "https://himo.example"},
		{name: "неверная версия", min: "latest", publicU: "https://himo.example", wantErr: true},
		{name: "нет PUBLIC_URL", wantErr: true},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			t.Setenv("DATABASE_URL", "postgres://localhost/himo")
			t.Setenv("PUBLIC_URL", tt.publicU)
			t.Setenv("MIN_APP_VERSION", tt.min)
			t.Setenv("TRUSTED_PROXIES", "172.17.0.0/16,10.0.0.1")

			cfg, err := Load()
			if (err != nil) != tt.wantErr {
				t.Fatalf("ошибка = %v, ожидалась: %v", err, tt.wantErr)
			}
			if err == nil && len(cfg.TrustedProxies) != 2 {
				t.Errorf("TrustedProxies = %v", cfg.TrustedProxies)
			}
		})
	}
}
