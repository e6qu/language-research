# 07 - Hello Prometheus Metrics

HTTP server with Prometheus metrics using `github.com/prometheus/client_golang`.

## Routes

- `GET /` — index
- `GET /work` — do work (increments counter + histogram)
- `GET /metrics` — Prometheus exposition format

## Dependencies

- `github.com/prometheus/client_golang`

## Build & Run

```bash
go mod download
go build -o hello ./...
./hello
# curl http://localhost:8080/work
# curl http://localhost:8080/metrics
```

## Test

```bash
go test -v ./...
```
