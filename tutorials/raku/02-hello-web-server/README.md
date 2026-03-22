# 02-hello-web-server

Minimal Raku web server using `IO::Socket::INET` with JSON responses.

## Usage

```bash
make build   # syntax check
make test    # run tests
make e2e     # start server, curl, verify
```

## Structure

- `lib/Server.rakumod` — request handler and server
- `bin/server.raku` — entry point
- `t/server.rakutest` — unit tests for handler
