# 07-hello-prometheus-metrics

Axum server exposing Prometheus metrics at `/metrics` with a `/work` endpoint that increments a counter.

## Run

```bash
cargo run
# curl -X POST http://localhost:3000/work
# curl http://localhost:3000/metrics
```

## Test

```bash
cargo test
```
