# 06 - Hello Structured Logging

Structured JSON logging using `log/slog` (stdlib since Go 1.21).

## Features

- JSON handler for machine-readable logs
- Typed fields (string, int, float64)
- Info and Error levels
- Zero external dependencies

## Build & Run

```bash
go build -o hello ./...
./hello
```

## Test

```bash
go test -v ./...
```
