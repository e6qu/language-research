# 08 - Hello OpenAPI Schema

OpenAPI 3.0 spec defined as Tcl dicts, rendered to JSON using a recursive encoder.

## Structure

- `src/openapi_spec.tcl` - OpenAPI spec builder, JSON encoder, and name validator
- `test/all.tcl` - Unit tests using tcltest
- `run.sh` - E2E test validating JSON output

## Usage

```bash
make test    # Run unit tests
make e2e     # Run end-to-end test
```

## Requirements

- Tcl 8.6+ or 9.0
