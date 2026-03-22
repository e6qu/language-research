# 01 - Hello World

Minimal Go program with a testable `Greet` function.

## Build & Run

```bash
go build -o hello ./...
./hello
```

## Test

```bash
go test -v ./...
```

## Structure

- `hello.go` — `Greet(name string) string` function
- `main.go` — entry point
- `hello_test.go` — table-driven tests
