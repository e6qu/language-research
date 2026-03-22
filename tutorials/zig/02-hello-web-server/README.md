# 02-hello-web-server

HTTP server using std.http.Server with JSON responses.

## Routes

- `GET /` -- service status
- `GET /greet/{name}` -- greeting
- Everything else -- 404

## Build & Run

```bash
zig build
./zig-out/bin/hello-web-server
```

## Test

```bash
zig build test
```
