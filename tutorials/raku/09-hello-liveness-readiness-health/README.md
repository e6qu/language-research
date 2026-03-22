# 09-hello-liveness-readiness-health

Kubernetes-style health checking with liveness, readiness, and dependency tracking.

## Usage

```bash
make build   # syntax check
make test    # run tests
make e2e     # verify health output
```

## Structure

- `lib/HealthChecker.rakumod` — health checker class with dep tracking
- `bin/health.raku` — demo script
- `t/health_checker.rakutest` — unit tests
