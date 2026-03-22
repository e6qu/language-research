# 07-hello-prometheus-metrics

In-memory counters and histograms served in Prometheus text format.

## Routes

- `GET /` -- returns "Hello, World!" (increments counter, records latency)
- `GET /metrics` -- Prometheus text exposition format

## Run

```bash
bash run.sh
curl localhost:8080/metrics
```

## Test

```bash
make test
```
