# Образ Himo Hub: веб на Node, сервер на Go, запуск на distroless не от root (ADR-015).
# Контекст сборки — корень репозитория: docker build -f hub/Dockerfile .
# Стадии web и build кешируются независимо: если менялся только hub/, веб не пересобирается, и наоборот.

FROM node:24-alpine AS web
WORKDIR /web

# Зависимости отдельным слоем: он пересобирается, только когда меняются package.json и package-lock.json.
COPY web/package.json web/package-lock.json ./
RUN npm ci --no-audit --no-fund

COPY web/ ./
RUN npm run build

FROM golang:1.23 AS build
WORKDIR /src

# Зависимости отдельным слоем: он пересобирается, только когда меняются go.mod и go.sum.
COPY hub/go.mod hub/go.sum ./
RUN go mod download

COPY hub/ ./
RUN CGO_ENABLED=0 go build -trimpath -ldflags="-s -w" -o /out/hub ./cmd/hub

FROM gcr.io/distroless/static-debian12:nonroot
COPY --from=build /out/hub /hub
COPY --from=web /web/build /web
ENV STATIC_DIR=/web
EXPOSE 8080
HEALTHCHECK --interval=10s --timeout=5s --start-period=10s --retries=3 CMD ["/hub", "healthcheck"]
ENTRYPOINT ["/hub"]
