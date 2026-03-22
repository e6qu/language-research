# 09-hello-liveness-readiness-health

Kubernetes-style health endpoints: `/healthz`, `/readyz`, and `/health` with dependency tracking.

## Run

```bash
cargo run
# curl http://localhost:3000/healthz
# curl http://localhost:3000/readyz
# curl http://localhost:3000/health
```

## Test

```bash
cargo test
```
