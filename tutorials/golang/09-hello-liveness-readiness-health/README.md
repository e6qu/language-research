# 09 - Hello Liveness Readiness Health

Kubernetes-style health check endpoints with a dependency tracker using `sync.RWMutex`.

## Routes

- `GET /healthz` — liveness probe (always 200 if process is running)
- `GET /readyz` — readiness probe (200 if all deps healthy, 503 otherwise)
- `GET /health` — detailed health with dependency list

## Concepts

- `sync.RWMutex` for thread-safe dependency tracking
- Separate liveness vs readiness semantics
- JSON responses for all endpoints

## Build & Run

```bash
go build -o hello ./...
./hello
# curl http://localhost:8080/health | jq
```

## Test

```bash
go test -v ./...
```
