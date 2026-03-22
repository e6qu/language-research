# 06 — Hello Structured Logging (C3)

JSON-line structured logging with level, component, and timestamp fields.

## Prerequisites

C3 is an experimental language. Install `c3c` from <https://c3-lang.org>.

## Usage

```bash
make build
./build/hello-logging
```

Output is one JSON object per line, suitable for piping to `jq`.
