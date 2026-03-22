# 01-hello-world

A minimal Scheme module that returns a greeting string.

## Prerequisites

- Guile 3.x

## Files

- `src/hello.scm` — greeting function with optional name parameter
- `test/run.scm` — unit tests using SRFI-64

## Usage

```bash
# Run tests
make test

# Run end-to-end check
make e2e

# Run everything
bash run.sh
```

## API

- `(greet)` — returns `"Hello, world!"`
- `(greet "Alice")` — returns `"Hello, Alice!"`
