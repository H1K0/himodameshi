# Развёртывание Himo Hub

Как устроено развёртывание и почему так — в [ADR-017](../docs/adr/017-deployment.md). Здесь — что лежит в каталоге и что настроить на Хакониве.

| Файл           | Назначение                                                                   |
| -------------- | ---------------------------------------------------------------------------- |
| `compose.yaml` | Одно описание окружения для dev и prod                                       |
| `deploy.sh`    | Разворачивает образ, ждёт `healthy`, при неудаче откатывает на прежний образ |

Workflow: [`hub-deploy-dev.yaml`](../.gitea/workflows/hub-deploy-dev.yaml) — при слиянии в `dev`, [`hub-deploy-prod.yaml`](../.gitea/workflows/hub-deploy-prod.yaml) — по тегу `hub/vX.Y.Z`.

## Окружения

|                | dev                             | prod                             |
| -------------- | ------------------------------- | -------------------------------- |
| Адрес          | `https://dev.himo.hakoniwa.ru`  | `https://himo.hakoniwa.ru`       |
| Порт на хосте  | `127.0.0.1:6746`                | `127.0.0.1:6744`                 |
| Образ          | `sha-<коммит>`                  | `X.Y.Z`                          |
| Compose-проект | `himo-hub-dev`                  | `himo-hub-prod`                  |
| Конфиг         | `/var/lib/himo-hub/dev/hub.env` | `/var/lib/himo-hub/prod/hub.env` |

Подсеть сети Docker выбирает сам. nginx приходит в контейнер с адреса шлюза этой сети, поэтому compose задаёт `TRUSTED_PROXIES` — весь диапазон Docker по умолчанию `172.16.0.0/12`; в `hub.env` его указывать не нужно. Это работает, пока в настройках демона Docker не изменён `default-address-pools`. Минус — `X-Forwarded-For` принимается от любого контейнера на сервере; для MVP это допустимо.

## Настройка сервера

### Каталог `/var/lib/himo-hub`

```
/var/lib/himo-hub/
├── dev/
│   └── hub.env
└── prod/
    └── hub.env
```

`hub.env` — переменные из [`hub/.env.example`](../hub/.env.example), права `600`. `HUB_ADDR` и `TRUSTED_PROXIES` задаёт compose, их значения из файла игнорируются. Для dev, например:

```
DATABASE_URL=postgres://himo_dev:<пароль>@host.docker.internal:5432/Himo_dev
PUBLIC_URL=https://dev.himo.hakoniwa.ru
TELEGRAM_BOT_TOKEN=<токен dev-бота>
```

### PostgreSQL

- Базы `Himo_dev` и `Himo_prod`, у каждой свой пользователь: `himo_dev` и `himo_prod`. Имена баз с заглавной буквой, поэтому в SQL их нужно брать в кавычки: `CREATE DATABASE "Himo_dev" OWNER himo_dev;`.
- `pg_hba.conf` пускает `himo_dev` в `Himo_dev` и `himo_prod` в `Himo_prod` из `172.16.0.0/12`.

### Runner

В `config.yaml` act_runner:

```yaml
runner:
  labels:
    # Метки, которые уже есть у runner'а, оставить; добавить:
    - "deploy:docker://docker.gitea.com/runner-images:ubuntu-latest"

container:
  # Задачи деплоя монтируют Docker хоста и конфиг окружений.
  valid_volumes:
    - /var/run/docker.sock
    - /var/lib/himo-hub
  # Не менять: "-" — Docker хоста не монтируется в задачи сам по себе.
  docker_host: "-"
```

После правки — перезапустить контейнер runner'а.

### Реестр

В настройках репозитория → Actions:

- переменная `REGISTRY_USER` — пользователь Gitea, от имени которого публикуются образы;
- секрет `REGISTRY_TOKEN` — его токен доступа с правом `write:package`.

### nginx

`dev.himo.hakoniwa.ru` → `http://127.0.0.1:6746`, `himo.hakoniwa.ru` → `http://127.0.0.1:6744`, с заголовками `X-Forwarded-For` и `X-Forwarded-Proto`. Для dev — ещё `X-Robots-Tag: noindex`.

## Вручную

Развернуть или откатить вручную — тот же скрипт на сервере из корня репозитория:

```bash
deploy/deploy.sh dev sha-1a2b3c4
```

Логи — `docker compose -p himo-hub-dev logs hub`.
