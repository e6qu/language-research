# 07-hello-prometheus-metrics (Common Lisp)

Prometheus-compatible metrics (counter, gauge, histogram) with text exposition format.

## Metric types

- **Counter**: monotonically increasing (e.g., total requests)
- **Gauge**: arbitrary value (e.g., active connections)
- **Histogram**: bucketed distribution (e.g., request duration)

## Usage

```bash
make test
bash run.sh      # render sample metrics
```

## Notes

- All metrics are thread-safe via `sb-thread:make-mutex`.
- `defstruct` inheritance (`:include`) models the metric type hierarchy.
- Output follows Prometheus text exposition format for direct scraping.
