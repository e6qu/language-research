# Tutorial 09 - Hello Liveness, Readiness & Health

Erlang/OTP application demonstrating health check endpoints using Cowboy and a gen_server.

## Endpoints

| Endpoint   | Purpose    | Description                          |
|------------|------------|--------------------------------------|
| `/healthz` | Liveness   | Always returns 200                   |
| `/readyz`  | Readiness  | 200 if all deps ok, 503 if degraded  |
| `/health`  | Detailed   | Per-dependency status as JSON        |

## Run

```bash
chmod +x run.sh
./run.sh
```

## Interactive Demo

```bash
rebar3 shell
```

```bash
curl localhost:8083/healthz
curl localhost:8083/readyz
curl localhost:8083/health
```
