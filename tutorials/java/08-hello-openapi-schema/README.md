# 08-hello-openapi-schema

OpenAPI 3.0.3 spec built as Java Maps, serialized to JSON, served via HttpServer.

## Routes

- `GET /api/openapi` -- OpenAPI JSON spec
- `GET /greet/{name}` -- JSON greeting

## Run

```bash
bash run.sh
curl localhost:8080/api/openapi
```

## Test

```bash
make test
```
