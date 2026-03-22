# 08 - Hello OpenAPI Schema

Minimal Elixir project that generates and serves an OpenAPI spec using `open_api_spex`.

## What it demonstrates

- Defining an OpenAPI spec with `OpenApiSpex.OpenApi` behaviour
- Defining schemas with `OpenApiSpex.schema/1`
- Serving the generated spec as JSON from a Plug.Router endpoint
- A simple greeting endpoint described in the spec

## Endpoints

- `GET /api/openapi` — returns the OpenAPI 3.0 spec as JSON
- `GET /api/greet?name=Alice` — returns `{"message": "Hello, Alice!"}`

## Run

```bash
chmod +x run.sh && ./run.sh
```
