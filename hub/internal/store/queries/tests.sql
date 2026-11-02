-- name: ListCableTests :many
-- История кабеля с автором, автором пометки и комментарием; столбцы те же, что в GetTestDetails.
SELECT sqlc.embed(t),
       author.nickname AS author_nickname, author.deleted_at AS author_deleted_at,
       invalidator.nickname AS invalidator_nickname, invalidator.deleted_at AS invalidator_deleted_at,
       i.body AS insight_body, i.model AS insight_model, i.created_at AS insight_created_at
FROM tests t
JOIN users author ON author.id = t.author_id
LEFT JOIN users invalidator ON invalidator.id = t.invalidated_by
LEFT JOIN insights i ON i.id = t.insight_id
WHERE t.cable_id = @cable_id
ORDER BY
    CASE WHEN NOT @descending::boolean THEN t.measured_at END ASC,
    CASE WHEN NOT @descending::boolean THEN t.id END ASC,
    CASE WHEN @descending::boolean THEN t.measured_at END DESC,
    CASE WHEN @descending::boolean THEN t.id END DESC
LIMIT @page_limit::bigint OFFSET @page_offset::bigint;

-- name: GetTestDetails :one
-- Тест со значениями для ответа API; столбцы те же, что в ListCableTests.
SELECT sqlc.embed(t),
       author.nickname AS author_nickname, author.deleted_at AS author_deleted_at,
       invalidator.nickname AS invalidator_nickname, invalidator.deleted_at AS invalidator_deleted_at,
       i.body AS insight_body, i.model AS insight_model, i.created_at AS insight_created_at
FROM tests t
JOIN users author ON author.id = t.author_id
LEFT JOIN users invalidator ON invalidator.id = t.invalidated_by
LEFT JOIN insights i ON i.id = t.insight_id
WHERE t.id = @id;

-- name: GetTest :one
SELECT * FROM tests
WHERE id = @id;

-- name: GetTestCableID :one
SELECT cable_id FROM tests
WHERE id = @id;

-- name: GetPreviousValidTestID :one
SELECT id FROM tests
WHERE cable_id = @cable_id AND invalidated_at IS NULL
  AND (measured_at, id) < (@measured_at::timestamptz, @id::uuid)
ORDER BY measured_at DESC, id DESC LIMIT 1;

-- name: GetReferenceTestID :one
-- Эталонный тест — первый действительный.
SELECT id FROM tests
WHERE cable_id = @cable_id AND invalidated_at IS NULL
ORDER BY measured_at, id LIMIT 1;

-- name: SetTestInvalidation :exec
UPDATE tests
SET invalidated_at = @invalidated_at, invalidated_by = @invalidated_by,
    invalidation_reason = @invalidation_reason, change_seq = @change_seq
WHERE id = @id;
