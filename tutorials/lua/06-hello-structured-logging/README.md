# 06-hello-structured-logging

JSON structured logging using dkjson in plain Lua 5.4.

## Overview

A structured logger that outputs JSON log entries with level, message, timestamp, and optional metadata fields. Uses the `dkjson` library for JSON encoding.

## Structure

- `src/logger.lua` - Logger with info/warn/error levels and metadata support
- `test/logger_test.lua` - Unit tests (JSON round-trip verification)
- `e2e/e2e_test.sh` - End-to-end JSON validation via python3

## Usage

```bash
make deps       # Install busted and dkjson via luarocks
make test       # Run unit tests
make e2e        # Run e2e tests
bash run.sh     # Run the demo
```
