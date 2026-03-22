# 07 - Hello Prometheus Metrics

In-memory metrics (counters and histograms) with Prometheus text format output.

## Usage

```bash
make deps
make test
make e2e
bash run.sh
```

## Structure

- `src/metrics.lua` - Metrics module with counter, histogram, format, and reset
- `test/metrics_test.lua` - Unit tests using busted
