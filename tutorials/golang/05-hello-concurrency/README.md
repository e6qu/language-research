# 05 - Hello Concurrency

Concurrent URL fetcher using goroutines, channels, and `sync.WaitGroup`.

## Concepts

- Goroutines for concurrent execution
- Channels for collecting results
- `sync.WaitGroup` for synchronization
- `httptest` for testing without real network calls

## Build & Run

```bash
go build -o hello ./...
./hello
```

## Test

```bash
go test -v ./...
```
