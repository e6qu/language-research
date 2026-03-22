# 07 - Hello Prometheus Metrics

In-memory metrics with Prometheus text exposition format. Supports counters and histograms.

## Structure

- `src/metrics.tcl` - Counter and histogram metrics with Prometheus text format output
- `test/all.tcl` - Unit tests using tcltest
- `run.sh` - E2E test validating metrics output

## Usage

```bash
make test    # Run unit tests
make e2e     # Run end-to-end test
```

## Requirements

- Tcl 8.6+ or 9.0
