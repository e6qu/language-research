# 08 - Hello OpenAPI Schema

OpenAPI 3.0 spec defined as a Lua table, served as JSON via dkjson.

## Usage

```bash
make deps
make test
make e2e
bash run.sh
```

## Structure

- `src/openapi_spec.lua` - OpenAPI spec builder, JSON serializer, name validator
- `test/openapi_spec_test.lua` - Unit tests using busted
