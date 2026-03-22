# 03-hello-cli

A minimal CLI argument parser using `(command-line)`.

## Prerequisites

- Guile 3.x

## Files

- `src/hello.scm` — argument parser and greeting formatter
- `test/run.scm` — unit tests using SRFI-64

## Usage

```bash
# Run tests
make test

# Run with arguments
guile src/hello.scm --name Alice --greeting Hi

# Show help
guile src/hello.scm --help
```
