# 07-hello-prometheus-metrics

Minimal Erlang tutorial: expose Prometheus metrics via Cowboy HTTP server.

## Run

```bash
chmod +x run.sh && ./run.sh
```

## Demo

```bash
rebar3 shell
# In another terminal:
curl localhost:8081/work
curl localhost:8081/metrics
```
