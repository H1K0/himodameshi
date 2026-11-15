-- name: ListCableTeams :many
-- Команды существующих кабелей пакета выгрузки, чтобы заблокировать их заранее.
SELECT id, team_id FROM cables
WHERE id = ANY(@ids::uuid[]);

-- name: LockTeams :many
-- Пакет выгрузки блокирует все свои команды одним запросом в порядке ID,
-- поэтому два пакета не заблокируют друг друга (data-model.md, раздел 5.3).
SELECT id FROM teams
WHERE id = ANY(@ids::uuid[])
ORDER BY id
FOR UPDATE;

-- name: ListAccessibleTeamIDs :many
-- Удалённые команды не видны, как и в GetMemberTeam.
SELECT t.id FROM teams t
JOIN team_members m ON m.team_id = t.id AND m.user_id = @user_id
WHERE t.id = ANY(@ids::uuid[]) AND t.deleted_at IS NULL;

-- name: InsertCable :execrows
-- Кабель с таким ID мог появиться в другой команде, пока шла проверка.
INSERT INTO cables (id, team_id, name, cable_type, color, note, created_by, created_at, change_seq)
VALUES (@id, @team_id, @name, @cable_type, @color, @note, @created_by, @created_at, @change_seq)
ON CONFLICT (id) DO NOTHING;

-- name: InsertTest :execrows
INSERT INTO tests (id, cable_id, author_id, measured_at, device_id, pv, app_version, rules_version,
                   firmware_version, health_score, health_incomplete, note, results, payload_hash, change_seq)
VALUES (@id, @cable_id, @author_id, @measured_at, @device_id, @pv, @app_version, @rules_version,
        @firmware_version, @health_score, @health_incomplete, @note, @results, @payload_hash, @change_seq)
ON CONFLICT (id) DO NOTHING;

-- name: ListSyncCables :many
-- Изменённые отслеживаемые кабели страницы загрузки; столбцы те же, что в GetCableDetails.
SELECT sqlc.embed(c),
       creator.nickname AS creator_nickname, creator.deleted_at AS creator_deleted_at,
       assignee.nickname AS assignee_nickname, assignee.deleted_at AS assignee_deleted_at,
       cur.health_score, stats.last_test_at, stats.test_count
FROM cables c
JOIN users creator ON creator.id = c.created_by
LEFT JOIN users assignee ON assignee.id = c.assignee_id
LEFT JOIN LATERAL (
    SELECT health_score FROM tests
    WHERE cable_id = c.id AND invalidated_at IS NULL
    ORDER BY measured_at DESC, id DESC LIMIT 1
) cur ON true
CROSS JOIN LATERAL (
    SELECT max(measured_at) AS last_test_at, count(*) AS test_count
    FROM tests WHERE cable_id = c.id
) stats
WHERE c.team_id = @team_id AND c.id = ANY(@ids::uuid[])
  AND c.change_seq > @after_seq::bigint AND c.change_seq <= @upto_seq::bigint
ORDER BY c.change_seq;

-- name: ListSyncTests :many
-- Новые и изменённые тесты отслеживаемых кабелей по возрастанию номера изменения;
-- столбцы те же, что в GetTestDetails.
SELECT sqlc.embed(t),
       author.nickname AS author_nickname, author.deleted_at AS author_deleted_at,
       invalidator.nickname AS invalidator_nickname, invalidator.deleted_at AS invalidator_deleted_at,
       i.body AS insight_body, i.model AS insight_model, i.created_at AS insight_created_at
FROM tests t
JOIN cables c ON c.id = t.cable_id AND c.team_id = @team_id
JOIN users author ON author.id = t.author_id
LEFT JOIN users invalidator ON invalidator.id = t.invalidated_by
LEFT JOIN insights i ON i.id = t.insight_id
WHERE t.cable_id = ANY(@ids::uuid[]) AND t.change_seq > @after_seq::bigint
ORDER BY t.change_seq, t.id
LIMIT @page_limit::bigint;

-- name: ListMissingCables :many
-- Отслеживаемые кабели, которых в команде больше нет: удалены или не из этой команды.
SELECT u.id::uuid AS id
FROM unnest(@ids::uuid[]) AS u(id)
WHERE NOT EXISTS (SELECT 1 FROM cables c WHERE c.id = u.id AND c.team_id = @team_id)
ORDER BY u.id;
