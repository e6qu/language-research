# 08 - Hello OpenAPI Schema

OpenAPI 3.0.3 spec defined as Go structs, served as JSON, with request validation.

## Routes

- `GET /` — greeting
- `GET /greet/{name}` — greet by name
- `POST /greet` — greet via JSON body `{"name":"..."}`
- `GET /api/openapi` — OpenAPI spec as JSON

## Build & Run

```bash
go build -o hello ./...
./hello
# curl http://localhost:8080/api/openapi | jq
```

## Test

```bash
go test -v ./...
```
