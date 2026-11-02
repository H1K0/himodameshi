package auth

import (
	"crypto/hmac"
	"crypto/sha256"
	"encoding/hex"
	"strings"
	"testing"
	"time"
)

func TestPassword(t *testing.T) {
	hash, err := HashPassword("correct horse")
	if err != nil {
		t.Fatal(err)
	}
	if !strings.HasPrefix(hash, "$argon2id$v=19$m=19456,t=2,p=1$") {
		t.Errorf("формат хеша: %q", hash)
	}

	if ok, err := VerifyPassword(hash, "correct horse"); err != nil || !ok {
		t.Errorf("верный пароль: ok=%v, err=%v", ok, err)
	}
	if ok, err := VerifyPassword(hash, "wrong horse"); err != nil || ok {
		t.Errorf("неверный пароль: ok=%v, err=%v", ok, err)
	}

	other, err := HashPassword("correct horse")
	if err != nil {
		t.Fatal(err)
	}
	if other == hash {
		t.Error("у двух хешей одна соль")
	}
}

func TestVerifyPasswordMalformedHash(t *testing.T) {
	for _, hash := range []string{"", "plain", "$bcrypt$a$b$c$d", "$argon2id$v=19$bad$c2FsdA$a2V5", "$argon2id$v=19$m=1,t=1,p=1$!$a2V5", "$argon2id$v=19$m=1,t=1,p=1$c2FsdA$!"} {
		if _, err := VerifyPassword(hash, "password"); err == nil {
			t.Errorf("хеш %q: ожидалась ошибка", hash)
		}
	}
}

func TestToken(t *testing.T) {
	a, err := NewToken()
	if err != nil {
		t.Fatal(err)
	}
	b, err := NewToken()
	if err != nil {
		t.Fatal(err)
	}
	if len(a) != 43 {
		t.Errorf("длина токена = %d, ожидалось 43", len(a))
	}
	if a == b {
		t.Error("токены совпали")
	}
	if len(HashToken(a)) != sha256.Size {
		t.Errorf("длина хеша = %d", len(HashToken(a)))
	}
}

func TestVerifyTelegram(t *testing.T) {
	const botToken = "123:bot-token"
	now := time.Unix(1_800_000_000, 0)
	fields := map[string]string{"id": "42", "first_name": "Vlad", "auth_date": "1800000000"}

	// Строка проверки — по документации Telegram: поля по алфавиту, через перевод строки.
	key := sha256.Sum256([]byte(botToken))
	mac := hmac.New(sha256.New, key[:])
	mac.Write([]byte("auth_date=1800000000\nfirst_name=Vlad\nid=42"))
	valid := hex.EncodeToString(mac.Sum(nil))

	tests := []struct {
		name     string
		botToken string
		hash     string
		fields   map[string]string
		authDate time.Time
		want     bool
	}{
		{"верная подпись", botToken, valid, fields, now, true},
		{"возраст ровно сутки", botToken, valid, fields, now.Add(-24 * time.Hour), true},
		{"старше суток", botToken, valid, fields, now.Add(-24*time.Hour - time.Second), false},
		{"другой токен бота", "other", valid, fields, now, false},
		{"нет токена бота", "", valid, fields, now, false},
		{"изменённое поле", botToken, valid, map[string]string{"id": "43", "first_name": "Vlad", "auth_date": "1800000000"}, now, false},
		{"подпись не hex", botToken, "zz", fields, now, false},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if got := VerifyTelegram(tt.botToken, tt.fields, tt.hash, tt.authDate, now); got != tt.want {
				t.Errorf("результат = %v, ожидался %v", got, tt.want)
			}
		})
	}
}
