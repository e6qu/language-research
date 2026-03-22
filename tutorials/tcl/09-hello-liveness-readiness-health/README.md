# 09 - Hello Liveness Readiness Health

Health check endpoints with liveness, readiness, and detailed health status.

## Structure

- `src/health_checker.tcl` - Health checker with dependency tracking and JSON responses
- `test/all.tcl` - Unit tests using tcltest
- `run.sh` - E2E test validating health check output

## Usage

```bash
make test    # Run unit tests
make e2e     # Run end-to-end test
```

## Requirements

- Tcl 8.6+ or 9.0
