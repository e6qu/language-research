# 09-hello-liveness-readiness-health

HTTP health check server with mutex-protected dependency state.

## Endpoints

- `/livez` -- always alive
- `/readyz` -- ready only if all dependencies are up
- `/healthz` -- detailed health with dependency checks

## Build & Run

```bash
zig build
./zig-out/bin/hello-liveness-readiness-health
```

## Test

```bash
zig build test
```
