# 08 - Hello OpenAPI Schema

Minimal Erlang tutorial: serve an OpenAPI 3.0 spec and a validated greeting endpoint using Cowboy and JSX.

## Run

```bash
chmod +x run.sh && ./run.sh
```

## Endpoints

- `GET /api/openapi` - returns the OpenAPI 3.0 spec as JSON
- `GET /api/greet?name=World` - returns `{"message":"Hello, World!"}`
- `GET /api/greet` (missing name) - returns 400 with error JSON
