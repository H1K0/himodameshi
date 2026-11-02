-- name: CreateUser :one
INSERT INTO users (id, nickname, password_hash)
VALUES (@id, @nickname, @password_hash)
RETURNING *;

-- name: GetUserByNickname :one
SELECT * FROM users
WHERE lower(nickname) = lower(@nickname) AND deleted_at IS NULL;

-- name: GetUserByTelegramID :one
SELECT * FROM users
WHERE telegram_id = @telegram_id AND deleted_at IS NULL;

-- name: UpdateNickname :one
UPDATE users SET nickname = @nickname
WHERE id = @id
RETURNING *;

-- name: UpdatePasswordHash :exec
UPDATE users SET password_hash = @password_hash
WHERE id = @id;

-- name: SetTelegram :one
UPDATE users SET telegram_id = @telegram_id, telegram_username = @telegram_username
WHERE id = @id
RETURNING *;

-- name: ClearTelegram :exec
UPDATE users SET telegram_id = NULL, telegram_username = NULL
WHERE id = @id;

-- name: AnonymizeUser :exec
UPDATE users
SET deleted_at = now(), password_hash = NULL, telegram_id = NULL, telegram_username = NULL
WHERE id = @id;
