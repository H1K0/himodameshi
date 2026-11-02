// Package store содержит запросы к БД, сгенерированные sqlc по internal/store/queries.
package store

//go:generate go run github.com/sqlc-dev/sqlc/cmd/sqlc@v1.27.0 generate -f ../../sqlc.yaml
