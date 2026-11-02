-- name: ListCables :many
-- Каталог команды: производные значения считаются при запросе (data-model.md, раздел 6).
-- Кабели без значения в поле сортировки идут последними в обоих направлениях.
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
WHERE c.team_id = @team_id
  AND (c.archived_at IS NOT NULL) = @archived::boolean
  AND (sqlc.narg('q')::text IS NULL OR strpos(lower(c.name), lower(sqlc.narg('q')::text)) > 0)
  AND (sqlc.narg('cable_type')::text IS NULL OR c.cable_type = sqlc.narg('cable_type')::text)
  AND (sqlc.narg('color')::text IS NULL OR c.color = sqlc.narg('color')::text)
  AND (sqlc.narg('assignee_id')::uuid IS NULL OR c.assignee_id = sqlc.narg('assignee_id')::uuid)
  AND (NOT @unassigned::boolean OR c.assignee_id IS NULL)
  AND CASE sqlc.narg('health')::text
          WHEN 'green' THEN cur.health_score >= 80
          WHEN 'yellow' THEN cur.health_score BETWEEN 40 AND 79
          WHEN 'red' THEN cur.health_score < 40
          WHEN 'none' THEN cur.health_score IS NULL
          ELSE true
      END
ORDER BY
    CASE WHEN @sort::text = 'last_test_at' AND NOT @descending::boolean THEN stats.last_test_at END ASC NULLS LAST,
    CASE WHEN @sort::text = 'last_test_at' AND @descending::boolean THEN stats.last_test_at END DESC NULLS LAST,
    CASE WHEN @sort::text = 'name' AND NOT @descending::boolean THEN lower(c.name) END ASC,
    CASE WHEN @sort::text = 'name' AND @descending::boolean THEN lower(c.name) END DESC,
    CASE WHEN @sort::text = 'health_score' AND NOT @descending::boolean THEN cur.health_score END ASC NULLS LAST,
    CASE WHEN @sort::text = 'health_score' AND @descending::boolean THEN cur.health_score END DESC NULLS LAST,
    c.id
LIMIT @page_limit::bigint OFFSET @page_offset::bigint;

-- name: CountCables :one
-- Те же фильтры, что в ListCables.
SELECT count(*)
FROM cables c
LEFT JOIN LATERAL (
    SELECT health_score FROM tests
    WHERE cable_id = c.id AND invalidated_at IS NULL
    ORDER BY measured_at DESC, id DESC LIMIT 1
) cur ON true
WHERE c.team_id = @team_id
  AND (c.archived_at IS NOT NULL) = @archived::boolean
  AND (sqlc.narg('q')::text IS NULL OR strpos(lower(c.name), lower(sqlc.narg('q')::text)) > 0)
  AND (sqlc.narg('cable_type')::text IS NULL OR c.cable_type = sqlc.narg('cable_type')::text)
  AND (sqlc.narg('color')::text IS NULL OR c.color = sqlc.narg('color')::text)
  AND (sqlc.narg('assignee_id')::uuid IS NULL OR c.assignee_id = sqlc.narg('assignee_id')::uuid)
  AND (NOT @unassigned::boolean OR c.assignee_id IS NULL)
  AND CASE sqlc.narg('health')::text
          WHEN 'green' THEN cur.health_score >= 80
          WHEN 'yellow' THEN cur.health_score BETWEEN 40 AND 79
          WHEN 'red' THEN cur.health_score < 40
          WHEN 'none' THEN cur.health_score IS NULL
          ELSE true
      END;

-- name: GetCableDetails :one
-- Кабель со значениями для ответа API; столбцы те же, что в ListCables.
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
WHERE c.id = @id;

-- name: CanReadCable :one
-- Удалённая команда не видна, как и в GetMemberTeam.
SELECT EXISTS (
    SELECT 1 FROM cables c
    JOIN teams t ON t.id = c.team_id AND t.deleted_at IS NULL
    JOIN team_members m ON m.team_id = t.id AND m.user_id = @user_id
    WHERE c.id = @id
);

-- name: GetCableTeamID :one
SELECT team_id FROM cables
WHERE id = @id;

-- name: GetCable :one
SELECT * FROM cables
WHERE id = @id;

-- name: CountCableTests :one
SELECT count(*) FROM tests
WHERE cable_id = @cable_id;

-- name: UpdateCable :exec
UPDATE cables
SET name = @name, cable_type = @cable_type, color = @color, note = @note, assignee_id = @assignee_id,
    version = version + 1, updated_at = now(), change_seq = @change_seq
WHERE id = @id;

-- name: SetCableArchivedAt :exec
UPDATE cables
SET archived_at = @archived_at, version = version + 1, updated_at = now(), change_seq = @change_seq
WHERE id = @id;

-- name: DeleteCable :exec
DELETE FROM cables
WHERE id = @id;
