# 06 - Hello Structured Logging

JSON structured logging using Tcl's built-in string manipulation. No external dependencies.

## Structure

- `src/logger.tcl` - JSON encoder and log functions (info, warn, error)
- `test/all.tcl` - Unit tests using tcltest
- `run.sh` - E2E test validating JSON output with python3

## Usage

```bash
make test    # Run unit tests
make e2e     # Run end-to-end test
```

## Requirements

- Tcl 8.6+ or 9.0
- python3 (for e2e JSON validation)
