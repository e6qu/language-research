# 06-hello-structured-logging

Structured JSON logging in Raku with hand-rolled serialization.

## Usage

```bash
make build   # syntax check
make test    # run tests
make e2e     # verify JSON output with python3
```

## Structure

- `lib/Logger.rakumod` — log-info, log-warn, log-error with metadata
- `bin/logger.raku` — demo script
- `t/logger.rakutest` — unit tests
