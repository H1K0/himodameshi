-- name: CreateSession :exec
INSERT INTO auth_sessions (user_id, token_hash, client, expires_at)
VALUES (@user_id, @token_hash, @client, @expires_at);

-- name: GetActiveSession :one
SELECT s.id, s.expires_at, sqlc.embed(u)
FROM auth_sessions s
JOIN users u ON u.id = s.user_id
WHERE s.token_hash = @token_hash
  AND s.revoked_at IS NULL
  AND s.expires_at > now()
  AND u.deleted_at IS NULL;

-- name: ExtendSession :exec
UPDATE auth_sessions SET expires_at = @expires_at
WHERE id = @id;

-- name: RevokeSession :exec
UPDATE auth_sessions SET revoked_at = now()
WHERE id = @id;

-- name: RevokeUserSessions :exec
UPDATE auth_sessions SET revoked_at = now()
WHERE user_id = @user_id AND revoked_at IS NULL;

-- name: RevokeOtherSessions :exec
UPDATE auth_sessions SET revoked_at = now()
WHERE user_id = @user_id AND id <> @keep_id AND revoked_at IS NULL;

-- name: DeleteUserSessions :exec
DELETE FROM auth_sessions WHERE user_id = @user_id;
