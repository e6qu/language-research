# 08 — Hello OpenAPI Schema

Type-safe API client generated from an OpenAPI spec.

## Structure

- `openapi-spec.json` — OpenAPI 3.0 spec defining a `/api/greet` endpoint
- `src/Api/Types.elm` — types derived from the schema
- `src/Api/Decoders.elm` — JSON decoders and encoders matching the schema
- `src/Api/Requests.elm` — HTTP request functions
- `src/Main.elm` — Browser.element app with text input and fetch button

## Run

```bash
bash run.sh
```
