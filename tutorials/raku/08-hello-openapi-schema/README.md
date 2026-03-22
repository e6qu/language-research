# 08-hello-openapi-schema

OpenAPI 3.0.3 spec definition and validation in Raku.

## Usage

```bash
make build   # syntax check
make test    # run tests
make e2e     # verify JSON output
```

## Structure

- `lib/OpenApiSpec.rakumod` — spec definition, validation, JSON serialization
- `bin/openapi.raku` — demo: print spec as JSON
- `t/openapi_spec.rakutest` — unit tests
