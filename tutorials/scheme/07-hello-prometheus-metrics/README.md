# 07-hello-prometheus-metrics

In-memory Prometheus metrics with exposition format output.

## Prerequisites

- Guile 3.x

## Files

- `src/hello.scm` — counter/gauge registry with Prometheus text format
- `test/run.scm` — unit tests using SRFI-64

## Usage

```bash
# Run tests
make test

# Start metrics server
guile src/hello.scm

# Fetch metrics
curl http://localhost:8080/metrics
```
