# 08-hello-openapi-schema

OpenAPI 3.0.3 spec defined as nested alists, serialized to JSON.

## Prerequisites

- Guile 3.x

## Files

- `src/hello.scm` — JSON serializer and OpenAPI spec as alists
- `test/run.scm` — unit tests using SRFI-64

## Usage

```bash
# Run tests
make test

# Output OpenAPI JSON
guile src/hello.scm
```
