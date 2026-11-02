-- name: CreatePersonalTeam :exec
INSERT INTO teams (id, name, is_personal)
VALUES (@id, @name, true);

-- name: AddTeamOwner :exec
INSERT INTO team_members (team_id, user_id, role)
VALUES (@team_id, @user_id, 'owner');

-- name: CreateTeam :exec
INSERT INTO teams (id, name, description)
VALUES (@id, @name, @description);

-- name: GetMemberTeam :one
-- Удалённая команда не видна: для участника её как будто нет (data-model.md, раздел 3.2).
SELECT sqlc.embed(t), m.role,
       (SELECT count(*) FROM team_members c WHERE c.team_id = t.id) AS member_count
FROM teams t
JOIN team_members m ON m.team_id = t.id
WHERE t.id = @id AND m.user_id = @user_id AND t.deleted_at IS NULL;

-- name: ListMemberTeams :many
SELECT sqlc.embed(t), m.role,
       (SELECT count(*) FROM team_members c WHERE c.team_id = t.id) AS member_count
FROM teams t
JOIN team_members m ON m.team_id = t.id
WHERE m.user_id = @user_id AND t.deleted_at IS NULL
ORDER BY t.is_personal DESC, t.id;

-- name: ListDeletedOwnedTeams :many
SELECT sqlc.embed(t), m.role,
       (SELECT count(*) FROM team_members c WHERE c.team_id = t.id) AS member_count
FROM teams t
JOIN team_members m ON m.team_id = t.id
WHERE m.user_id = @user_id AND m.role = 'owner' AND t.deleted_at > @deleted_after::timestamptz
ORDER BY t.deleted_at DESC;

-- name: LockTeam :one
-- Изменения состава и настроек команды идут по очереди. Роль читается следующим запросом,
-- уже после получения блокировки: иначе она могла бы оказаться устаревшей.
SELECT * FROM teams
WHERE id = @id
FOR UPDATE;

-- name: GetMemberRole :one
SELECT role FROM team_members
WHERE team_id = @team_id AND user_id = @user_id;

-- name: UpdateTeam :exec
UPDATE teams
SET name = coalesce(sqlc.narg('name'), name),
    description = coalesce(sqlc.narg('description'), description)
WHERE id = @id;

-- name: SoftDeleteTeam :exec
UPDATE teams SET deleted_at = now()
WHERE id = @id;

-- name: RestoreTeam :exec
UPDATE teams SET deleted_at = NULL
WHERE id = @id;

-- name: SetMemberRole :exec
UPDATE team_members SET role = @role
WHERE team_id = @team_id AND user_id = @user_id;

-- name: ListTeamMembers :many
SELECT u.id, u.nickname, u.deleted_at, m.role, m.joined_at
FROM team_members m
JOIN users u ON u.id = m.user_id
WHERE m.team_id = @team_id
ORDER BY m.role = 'owner' DESC, m.joined_at, u.id;

-- name: CountOwnedTeamsWithMembers :one
-- Действующие команды пользователя, где кроме него есть другие участники.
SELECT count(*)
FROM team_members own
JOIN teams t ON t.id = own.team_id AND t.deleted_at IS NULL
WHERE own.user_id = @user_id
  AND own.role = 'owner'
  AND EXISTS (
      SELECT 1 FROM team_members other
      WHERE other.team_id = own.team_id AND other.user_id <> own.user_id
  );

-- name: DeleteOwnedTeams :exec
DELETE FROM teams
WHERE id IN (
    SELECT team_id FROM team_members
    WHERE user_id = @user_id AND role = 'owner'
);

-- name: ListMemberTeamIDs :many
-- Порядок по ID: строки teams блокируются в одном порядке (data-model.md, раздел 5.3).
SELECT team_id FROM team_members
WHERE user_id = @user_id
ORDER BY team_id;

-- name: RemoveTeamMember :exec
DELETE FROM team_members
WHERE team_id = @team_id AND user_id = @user_id;

-- name: ListAssignedCableIDs :many
SELECT id FROM cables
WHERE team_id = @team_id AND assignee_id = @user_id
ORDER BY id
FOR UPDATE;

-- name: AdvanceChangeSeq :one
UPDATE teams SET change_seq = change_seq + @n::bigint
WHERE id = @id
RETURNING change_seq;

-- name: ClearCableAssignee :exec
UPDATE cables
SET assignee_id = NULL, version = version + 1, updated_at = now(), change_seq = @change_seq
WHERE id = @id;

-- name: InsertAuditEvent :exec
INSERT INTO audit_events (team_id, actor_id, event, cable_id, test_id, subject_user_id, details)
VALUES (@team_id, @actor_id, @event, @cable_id, @test_id, @subject_user_id, @details);
