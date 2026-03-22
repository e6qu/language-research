# 09-hello-liveness-readiness-health

Kubernetes-style health endpoints using JDK HttpServer and ConcurrentHashMap.

## Routes

- `GET /healthz` -- liveness probe (200 OK / 503)
- `GET /readyz` -- readiness probe (200 READY / 503 NOT READY)
- `GET /health` -- full JSON health with dependency status

## Run

```bash
bash run.sh
curl localhost:8080/healthz
curl localhost:8080/readyz
curl localhost:8080/health
```

## Test

```bash
make test
```
