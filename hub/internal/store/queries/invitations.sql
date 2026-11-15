-- Приглашения в команду: docs/spec/hub/data-model.md, раздел 3.3.
-- Токен ссылки в БД не хранится — только его SHA-256 (token_hash), как у сеансов (ADR-022).

-- name: CreateInvitation :one
INSERT INTO invitations (id, team_id, token_hash, created_by, expires_at)
VALUES (@id, @team_id, @token_hash, @created_by, @expires_at)
RETURNING *;

-- name: ListTeamInvitations :many
-- Действующие приглашения команды: не истёкшие, не отозванные, не использованные.
-- created_by отдаётся как UserRef: ник скрыт у обезличенного создателя.
SELECT i.id, i.team_id, i.created_by, i.created_at, i.expires_at,
       u.nickname AS created_by_nickname, u.deleted_at AS created_by_deleted_at
FROM invitations i
JOIN users u ON u.id = i.created_by
WHERE i.team_id = @team_id
  AND i.revoked_at IS NULL
  AND i.used_at IS NULL
  AND i.expires_at > now()
ORDER BY i.created_at DESC, i.id;

-- name: GetInvitationByID :one
-- Для отзыва: блокирует строку приглашения. Команда не должна быть удалена —
-- отзывать приглашение в удалённую команду нет смысла, и это скрывает существование.
SELECT i.id, i.team_id, t.deleted_at AS team_deleted_at
FROM invitations i
JOIN teams t ON t.id = i.team_id
WHERE i.id = @id
FOR UPDATE OF i;

-- name: RevokeInvitation :execrows
-- Отзывает только ещё действующее приглашение; число затронутых строк показывает,
-- было ли изменение (для записи в журнал).
UPDATE invitations SET revoked_at = now()
WHERE id = @id AND revoked_at IS NULL;

-- name: GetInvitationPreview :one
-- Предпросмотр по токену без входа: только действующее приглашение в действующей команде.
SELECT t.name AS team_name, i.expires_at
FROM invitations i
JOIN teams t ON t.id = i.team_id
WHERE i.token_hash = @token_hash
  AND i.revoked_at IS NULL
  AND i.used_at IS NULL
  AND i.expires_at > now()
  AND t.deleted_at IS NULL;

-- name: LockInvitationByToken :one
-- Блокирует приглашение для вступления. Команда не удалена; пригодность проверяется
-- под блокировкой, чтобы двое одновременно не вступили по одноразовой ссылке.
SELECT i.id, i.team_id, i.expires_at, i.revoked_at, i.used_by
FROM invitations i
JOIN teams t ON t.id = i.team_id AND t.deleted_at IS NULL
WHERE i.token_hash = @token_hash
FOR UPDATE OF i;

-- name: UseInvitation :exec
-- Помечает приглашение использованным вступившим. Условие used_by IS NULL — страховка
-- на случай, если блокировка строки не удержала (другой уровень изоляции, сбой).
UPDATE invitations
SET used_by = @used_by, used_at = now()
WHERE id = @id AND used_by IS NULL AND used_at IS NULL;