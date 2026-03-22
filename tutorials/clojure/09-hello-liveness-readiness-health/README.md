# 09-hello-liveness-readiness-health

Kubernetes-style health check endpoints with atom-based dependency tracking.

## Run

```bash
bash run.sh
curl http://localhost:4029/healthz
curl http://localhost:4029/readyz
curl http://localhost:4029/health
```

## Test

```bash
make test
```
