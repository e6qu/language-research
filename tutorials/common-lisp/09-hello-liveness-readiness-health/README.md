# 09-hello-liveness-readiness-health (Common Lisp)

Kubernetes-style health check endpoints with pluggable checks.

## Endpoints

- `GET /livez` - liveness probe (always 200 if process alive)
- `GET /readyz` - readiness probe (200 when explicitly set ready, 503 otherwise)
- `GET /healthz` - full health (runs all registered checks, 503 if any fail)

## Usage

```bash
make test
bash run.sh          # start on :8080
curl localhost:8080/livez
curl localhost:8080/readyz
curl localhost:8080/healthz
```

## Notes

- `handler-case` catches errors in health check functions, preventing one bad check from crashing the server.
- Thread-safe state via `sb-thread:make-mutex`.
- The condition system's `handler-bind` could provide restarts for failing checks (e.g., retry, use-cached-value), but `handler-case` suffices here.
