# 06-hello-structured-logging

Structured JSON logging built from scratch.

## Prerequisites

- Guile 3.x

## Files

- `src/hello.scm` — JSON builder and log functions (info, warn, error)
- `test/run.scm` — unit tests using SRFI-64

## Usage

```bash
# Run tests
make test

# Run logging demo
guile src/hello.scm
```
