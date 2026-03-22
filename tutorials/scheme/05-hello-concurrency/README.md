# 05-hello-concurrency

Parallel computation using Guile's `(ice-9 futures)`.

## Prerequisites

- Guile 3.x

## Files

- `src/hello.scm` — parallel-map vs sequential-map with timing
- `test/run.scm` — unit tests using SRFI-64

## Usage

```bash
# Run tests
make test

# Run concurrency demo
guile src/hello.scm
```
