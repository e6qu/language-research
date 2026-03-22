# 03 - Hello CLI

Command-line tool using the `flag` package from the standard library.

## Flags

- `--name` — name to greet (default: "World")
- `--shout` — uppercase the greeting

## Build & Run

```bash
go build -o hello ./...
./hello -name Gopher -shout
```

## Test

```bash
go test -v ./...
```
