# 07-hello-prometheus-metrics

Prometheus-compatible metrics (counters, histograms) in Raku.

## Usage

```bash
make build   # syntax check
make test    # run tests
make e2e     # verify metric output
```

## Structure

- `lib/Metrics.rakumod` — counters, histograms, Prometheus text format
- `bin/metrics.raku` — demo script
- `t/metrics.rakutest` — unit tests
