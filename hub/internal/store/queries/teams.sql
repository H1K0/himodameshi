-- name: CreatePersonalTeam :exec
INSERT INTO teams (id, name, is_personal)
VALUES (@id, @name, true);

-- name: AddTeamOwner :exec
INSERT INTO team_members (team_id, user_id, role)
VALUES (@team_id, @user_id, 'owner');

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
INSERT INTO audit_events (team_id, actor_id, event, cable_id, subject_user_id, details)
VALUES (@team_id, @actor_id, @event, @cable_id, @subject_user_id, @details);
