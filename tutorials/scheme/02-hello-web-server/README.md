# 02-hello-web-server

A minimal HTTP server using Guile's built-in `(web server)` module.

## Prerequisites

- Guile 3.x

## Files

- `src/hello.scm` — HTTP handler and server startup
- `test/run.scm` — unit tests for the handler function using SRFI-64

## Usage

```bash
# Run tests
make test

# Run end-to-end check
make e2e

# Start server
guile src/hello.scm
```

## Endpoints

- `GET /` — returns `"Hello, world!"`
- `GET /health` — returns `"OK"`
