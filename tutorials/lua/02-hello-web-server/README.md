# 02-hello-web-server

A minimal HTTP JSON server built with LuaSocket.

## Prerequisites

- Lua 5.4
- busted (`luarocks install busted`)
- luasocket (`luarocks install luasocket`)

## Files

- `src/server.lua` — HTTP server with request handling and response formatting
- `test/server_test.lua` — unit tests for request handling (no network needed)

## Usage

```bash
# Run tests
make test

# Run end-to-end check
make e2e

# Start the server
bash run.sh
```

## Endpoints

- `GET /` — returns `{"message":"Hello, world!"}`
- `GET /greet/:name` — returns `{"message":"Hello, :name!"}`
- Any other path — returns 404
