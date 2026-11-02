-- Схема Himo Hub: docs/spec/hub/data-model.md, раздел 3.

-- +goose Up

-- Пользователи. Строки не удаляются физически: при удалении учётной записи
-- стираются пароль и Telegram, автор тестов показывается как «Удалённый пользователь».
CREATE TABLE users (
    id                 uuid        PRIMARY KEY,
    nickname           text        NOT NULL,
    password_hash      text,                      -- NULL у удалённых
    telegram_id        bigint      UNIQUE,
    telegram_username  text,
    created_at         timestamptz NOT NULL DEFAULT now(),
    deleted_at         timestamptz
);
-- Ник уникален без учёта регистра среди действующих пользователей.
CREATE UNIQUE INDEX users_nickname_uq ON users (lower(nickname)) WHERE deleted_at IS NULL;

-- Сеансы веба и приложения (ADR-022).
CREATE TABLE auth_sessions (
    id          bigint      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id     uuid        NOT NULL REFERENCES users ON DELETE CASCADE,
    token_hash  bytea       NOT NULL UNIQUE,      -- SHA-256 токена, сам токен не хранится
    client      text        NOT NULL CHECK (client IN ('web', 'app')),
    created_at  timestamptz NOT NULL DEFAULT now(),
    expires_at  timestamptz NOT NULL,
    revoked_at  timestamptz
);
CREATE INDEX auth_sessions_user_idx ON auth_sessions (user_id);

-- Команды, в том числе личные пространства.
CREATE TABLE teams (
    id           uuid        PRIMARY KEY,
    name         text        NOT NULL,
    description  text        NOT NULL DEFAULT '',
    is_personal  boolean     NOT NULL DEFAULT false,
    plan         text        NOT NULL DEFAULT 'free',  -- ключ тарифа, лимиты — в конфигурации
    change_seq   bigint      NOT NULL DEFAULT 0,       -- счётчик изменений для синхронизации
    created_at   timestamptz NOT NULL DEFAULT now(),
    deleted_at   timestamptz                           -- восстановление в течение 30 суток
);

CREATE TABLE team_members (
    team_id    uuid        NOT NULL REFERENCES teams ON DELETE CASCADE,
    user_id    uuid        NOT NULL REFERENCES users,
    role       text        NOT NULL CHECK (role IN ('owner', 'member')),
    joined_at  timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (team_id, user_id)
);
-- Не больше одного владельца в команде.
CREATE UNIQUE INDEX team_members_owner_uq ON team_members (team_id) WHERE role = 'owner';
CREATE INDEX team_members_user_idx ON team_members (user_id);

-- Одноразовые приглашения.
CREATE TABLE invitations (
    id          uuid        PRIMARY KEY,
    team_id     uuid        NOT NULL REFERENCES teams ON DELETE CASCADE,
    token_hash  bytea       NOT NULL UNIQUE,
    created_by  uuid        NOT NULL REFERENCES users,
    created_at  timestamptz NOT NULL DEFAULT now(),
    expires_at  timestamptz NOT NULL,
    revoked_at  timestamptz,
    used_by     uuid        REFERENCES users,
    used_at     timestamptz,
    CHECK ((used_by IS NULL) = (used_at IS NULL))
);
CREATE INDEX invitations_team_idx ON invitations (team_id);

CREATE TABLE cables (
    id           uuid        PRIMARY KEY,          -- UUIDv7 из приложения
    team_id      uuid        NOT NULL REFERENCES teams ON DELETE CASCADE,
    name         text        NOT NULL,
    cable_type   text        NOT NULL CHECK (cable_type IN ('jack_ts', 'jack_trs', 'xlr')),
    color        text        NOT NULL CHECK (color ~ '^[0-9a-f]{6}$'),
    note         text,
    assignee_id  uuid        REFERENCES users,
    created_by   uuid        NOT NULL REFERENCES users,
    created_at   timestamptz NOT NULL,             -- время создания в приложении
    updated_at   timestamptz NOT NULL DEFAULT now(),
    version      integer     NOT NULL DEFAULT 1,   -- оптимистичная блокировка
    archived_at  timestamptz,
    change_seq   bigint      NOT NULL
);
CREATE INDEX cables_team_seq_idx ON cables (team_id, change_seq);

-- Кэш ИИ-комментариев (ADR-018).
CREATE TABLE insights (
    id              uuid        PRIMARY KEY,
    cache_key       bytea       NOT NULL UNIQUE,   -- SHA-256(канонические результаты + версия промпта + модель)
    prompt_version  text        NOT NULL,
    model           text        NOT NULL,
    body            text        NOT NULL,
    created_at      timestamptz NOT NULL DEFAULT now()
);
-- Для дневного лимита обращений к модели: count(*) за текущие сутки.
CREATE INDEX insights_created_idx ON insights (created_at);

CREATE TABLE tests (
    id                   uuid        PRIMARY KEY,  -- UUIDv7 из приложения
    cable_id             uuid        NOT NULL REFERENCES cables ON DELETE CASCADE,
    author_id            uuid        NOT NULL REFERENCES users,  -- кто выгрузил
    measured_at          timestamptz NOT NULL,     -- часы приложения
    received_at          timestamptz NOT NULL DEFAULT now(),
    device_id            text        NOT NULL,
    pv                   smallint    NOT NULL,
    app_version          text        NOT NULL,
    rules_version        text        NOT NULL,
    firmware_version     text,
    health_score         smallint    CHECK (health_score BETWEEN 0 AND 100),
    health_incomplete    boolean     NOT NULL,
    note                 text,
    results              jsonb       NOT NULL,
    payload_hash         bytea       NOT NULL,     -- для идемпотентной выгрузки
    insight_id           uuid        REFERENCES insights ON DELETE SET NULL,
    invalidated_at       timestamptz,
    invalidated_by       uuid        REFERENCES users,
    invalidation_reason  text,
    change_seq           bigint      NOT NULL,
    CHECK ((invalidated_at IS NULL) = (invalidated_by IS NULL)
       AND (invalidated_at IS NULL) = (invalidation_reason IS NULL))
);
-- История кабеля, предыдущий и эталонный тест, последний тест для каталога.
CREATE INDEX tests_cable_history_idx ON tests (cable_id, measured_at, id);
CREATE INDEX tests_cable_seq_idx     ON tests (cable_id, change_seq);

-- Журнал действий команды. Ссылок на кабели и тесты нет намеренно:
-- записи должны пережить окончательное удаление кабеля.
CREATE TABLE audit_events (
    id               bigint      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    team_id          uuid        NOT NULL REFERENCES teams ON DELETE CASCADE,
    actor_id         uuid        NOT NULL REFERENCES users,
    event            text        NOT NULL,
    cable_id         uuid,
    test_id          uuid,
    subject_user_id  uuid        REFERENCES users, -- кого пригласили, исключили, назначили
    details          jsonb       NOT NULL DEFAULT '{}',  -- было / стало, имя кабеля
    created_at       timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX audit_events_team_idx  ON audit_events (team_id, created_at DESC);
CREATE INDEX audit_events_cable_idx ON audit_events (cable_id) WHERE cable_id IS NOT NULL;

-- +goose Down

DROP TABLE audit_events;
DROP TABLE tests;
DROP TABLE insights;
DROP TABLE cables;
DROP TABLE invitations;
DROP TABLE team_members;
DROP TABLE teams;
DROP TABLE auth_sessions;
DROP TABLE users;
