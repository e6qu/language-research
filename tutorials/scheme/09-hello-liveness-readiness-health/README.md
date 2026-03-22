# 09-hello-liveness-readiness-health

Kubernetes-style health checks with mutable state.

## Prerequisites

- Guile 3.x

## Files

- `src/hello.scm` — health check server with liveness/readiness/combined endpoints
- `test/run.scm` — unit tests for state and handler using SRFI-64

## Usage

```bash
# Run tests
make test

# Start health server
guile src/hello.scm

# Check endpoints
curl http://localhost:8080/healthz   # liveness
curl http://localhost:8080/readyz    # readiness
curl http://localhost:8080/health    # combined
```
