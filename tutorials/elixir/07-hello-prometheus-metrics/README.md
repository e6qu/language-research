# 07 - Hello Prometheus Metrics

Expose Prometheus-format metrics from an Elixir web app using Telemetry and `telemetry_metrics_prometheus`.

## What it does

- `GET /work` -- simulates work, emits a telemetry event with a random duration, returns JSON.
- `GET /metrics` -- returns all collected metrics in Prometheus text format.

## Key modules

| Module | Role |
|--------|------|
| `HelloMetrics.Telemetry` | Defines which metrics to track (counter + last_value) |
| `HelloMetrics.Router` | Plug router with `/work` and `/metrics` endpoints |
| `HelloMetrics.Application` | Starts TelemetryMetricsPrometheus and Bandit |

## Run

```bash
bash run.sh
```

Or manually:

```bash
mix deps.get
mix test --trace
elixir --no-halt -S mix   # then visit http://localhost:4001/work
```
