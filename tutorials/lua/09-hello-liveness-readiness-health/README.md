# 09 - Hello Liveness Readiness Health

Health checker module with dependency tracking, liveness, and readiness endpoints.

## Usage

```bash
make deps
make test
make e2e
bash run.sh
```

## Structure

- `src/health_checker.lua` - Health checker with dependency tracking and JSON output
- `test/health_checker_test.lua` - Unit tests using busted
