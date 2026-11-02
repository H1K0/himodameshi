// Package auth реализует пароли, токены сеансов и проверку данных Telegram (ADR-022).
package auth

import (
	"crypto/hmac"
	"crypto/rand"
	"crypto/sha256"
	"crypto/subtle"
	"encoding/base64"
	"encoding/hex"
	"errors"
	"fmt"
	"sort"
	"strings"
	"time"

	"golang.org/x/crypto/argon2"
)

// Параметры Argon2id — рекомендации OWASP.
const (
	argonMemory  = 19 * 1024 // КиБ
	argonTime    = 2
	argonThreads = 1
	argonSaltLen = 16
	argonKeyLen  = 32
)

// telegramMaxAge — насколько старым может быть auth_date.
const telegramMaxAge = 24 * time.Hour

var b64 = base64.RawStdEncoding

// HashPassword возвращает хеш пароля в формате PHC.
func HashPassword(password string) (string, error) {
	salt := make([]byte, argonSaltLen)
	if _, err := rand.Read(salt); err != nil {
		return "", err
	}
	key := argon2.IDKey([]byte(password), salt, argonTime, argonMemory, argonThreads, argonKeyLen)
	return fmt.Sprintf("$argon2id$v=%d$m=%d,t=%d,p=%d$%s$%s",
		argon2.Version, argonMemory, argonTime, argonThreads, b64.EncodeToString(salt), b64.EncodeToString(key)), nil
}

// VerifyPassword сравнивает пароль с хешем; параметры берутся из самого хеша.
func VerifyPassword(hash, password string) (bool, error) {
	parts := strings.Split(hash, "$")
	if len(parts) != 6 || parts[1] != "argon2id" {
		return false, errors.New("unsupported password hash format")
	}
	var memory, iterations uint32
	var threads uint8
	if _, err := fmt.Sscanf(parts[3], "m=%d,t=%d,p=%d", &memory, &iterations, &threads); err != nil {
		return false, fmt.Errorf("parse password hash params: %w", err)
	}
	salt, err := b64.DecodeString(parts[4])
	if err != nil {
		return false, fmt.Errorf("decode password hash salt: %w", err)
	}
	want, err := b64.DecodeString(parts[5])
	if err != nil {
		return false, fmt.Errorf("decode password hash key: %w", err)
	}
	got := argon2.IDKey([]byte(password), salt, iterations, memory, threads, uint32(len(want)))
	return subtle.ConstantTimeCompare(got, want) == 1, nil
}

// NewToken возвращает новый токен сеанса: 32 случайных байта в base64url.
func NewToken() (string, error) {
	raw := make([]byte, 32)
	if _, err := rand.Read(raw); err != nil {
		return "", err
	}
	return base64.RawURLEncoding.EncodeToString(raw), nil
}

// HashToken возвращает SHA-256 токена — в таком виде он хранится в БД.
func HashToken(token string) []byte {
	sum := sha256.Sum256([]byte(token))
	return sum[:]
}

// VerifyTelegram проверяет подпись данных Login Widget и свежесть auth_date.
// fields — все поля виджета, кроме hash. Без токена бота подпись считается неверной:
// ключ от пустого токена известен всем.
func VerifyTelegram(botToken string, fields map[string]string, hash string, authDate, now time.Time) bool {
	if botToken == "" || now.Sub(authDate) > telegramMaxAge {
		return false
	}
	want, err := hex.DecodeString(hash)
	if err != nil {
		return false
	}

	lines := make([]string, 0, len(fields))
	for k, v := range fields {
		lines = append(lines, k+"="+v)
	}
	sort.Strings(lines)

	key := sha256.Sum256([]byte(botToken))
	mac := hmac.New(sha256.New, key[:])
	mac.Write([]byte(strings.Join(lines, "\n")))
	return hmac.Equal(mac.Sum(nil), want)
}
