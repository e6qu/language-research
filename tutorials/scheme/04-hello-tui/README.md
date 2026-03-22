# 04-hello-tui

A minimal TUI with ANSI escape codes and state as association lists.

## Prerequisites

- Guile 3.x

## Files

- `src/hello.scm` — TUI renderer with j/k navigation, q to quit
- `test/run.scm` — unit tests for state transitions using SRFI-64

## Usage

```bash
# Run tests
make test

# Run TUI interactively
guile src/hello.scm
```
