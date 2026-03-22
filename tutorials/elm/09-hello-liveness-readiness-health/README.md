# 09 — Hello Liveness, Readiness & Health

Minimal Elm app that polls three health endpoints and displays status cards.

## Endpoints

| Path | Purpose |
|------|---------|
| `/healthz` | Liveness — is the process alive? |
| `/readyz` | Readiness — can it serve traffic? |
| `/health` | Detailed — per-dependency checks |

Expected JSON shapes:

```json
// /healthz and /readyz
{"status": "ok"}

// /health
{"checks": {"database": {"status": "ok"}, "cache": {"status": "degraded"}}}
```

## Run

```bash
bash run.sh
```

Tests run first, then the app is compiled to `elm.js`. Open `index.html` with a backend serving the endpoints above.
