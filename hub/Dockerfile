# Образ Himo Hub: сборка на Go, запуск на distroless не от root (ADR-015).
# Контекст сборки — каталог hub/.

FROM golang:1.23 AS build
WORKDIR /src

# Зависимости отдельным слоем: он пересобирается, только когда меняются go.mod и go.sum.
COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 go build -trimpath -ldflags="-s -w" -o /out/hub ./cmd/hub

FROM gcr.io/distroless/static-debian12:nonroot
COPY --from=build /out/hub /hub
EXPOSE 8080
HEALTHCHECK --interval=10s --timeout=5s --start-period=10s --retries=3 CMD ["/hub", "healthcheck"]
ENTRYPOINT ["/hub"]
