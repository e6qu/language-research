# 04 - Hello TUI

Interactive terminal UI with a selectable list using `golang.org/x/term` and ANSI escape codes.

## Controls

- Arrow keys or j/k to navigate
- Enter to select
- q to quit

## Dependencies

- `golang.org/x/term` for raw terminal mode

## Build & Run

```bash
go build -o hello ./...
./hello
```

## Test

```bash
go test -v ./...
```
