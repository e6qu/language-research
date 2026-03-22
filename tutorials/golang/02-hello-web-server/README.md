# 02 - Hello Web Server

Minimal HTTP server using `net/http` from the standard library.

## Routes

- `GET /` — JSON greeting
- `GET /greet/{name}` — JSON greeting by name
- Everything else — 404 JSON response

## Build & Run

```bash
go build -o hello ./...
./hello
# http://localhost:8080/
```

## Test

```bash
go test -v ./...
```
