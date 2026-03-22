# 09 — Hello Liveness, Readiness & Health

Minimal Elixir project demonstrating Kubernetes-style health check endpoints using Plug, Bandit, and a GenServer dependency checker.

## Endpoints

| Path | Purpose | Response |
|-----------|-------------|----------------------------------------------|
| `/healthz` | Liveness | Always `200 {"status":"ok"}` |
| `/readyz` | Readiness | `200` if all deps ok, `503` if degraded |
| `/health` | Detailed | `200` with per-dependency status |

## Run

```bash
chmod +x run.sh && ./run.sh
```
