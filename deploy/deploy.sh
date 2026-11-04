#!/usr/bin/env bash
# Разворачивает образ Hub в окружении и ждёт статуса healthy.
# Если контейнер не стал здоровым, возвращает прежний образ и завершается с ошибкой (ADR-017).
# Использование: deploy/deploy.sh <dev|prod> <тег образа>
set -euo pipefail

export HIMO_ENV="$1" HUB_TAG="$2"
case "$HIMO_ENV" in
  prod) export HUB_PORT=6744 ;;
  dev) export HUB_PORT=6746 ;;
  *)
    echo "Неизвестное окружение: $HIMO_ENV" >&2
    exit 2
    ;;
esac

WAIT_TIMEOUT=90

compose() {
  docker compose -f "$(dirname "$0")/compose.yaml" "$@"
}

# Тег образа, который работает сейчас, — на него откатываемся.
prev=""
id=$(compose ps -q hub 2>/dev/null || true)
if [ -n "$id" ]; then
  image=$(docker inspect --format '{{.Config.Image}}' "$id")
  prev=${image##*:}
fi

compose pull hub
if compose up -d --wait --wait-timeout "$WAIT_TIMEOUT" hub; then
  echo "Hub $HUB_TAG развёрнут в $HIMO_ENV"
  exit 0
fi

echo "Hub $HUB_TAG не стал healthy за $WAIT_TIMEOUT с" >&2
compose logs --tail 100 hub >&2 || true

if [ -n "$prev" ] && [ "$prev" != "$HUB_TAG" ]; then
  echo "Откат на $prev" >&2
  export HUB_TAG="$prev"
  compose up -d --wait --wait-timeout "$WAIT_TIMEOUT" hub || echo "Откат не удался" >&2
fi
exit 1
