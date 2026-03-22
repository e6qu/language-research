# 08-hello-openapi-schema (Common Lisp)

OpenAPI 3.0 spec builder using nested alists, rendered to JSON.

## Features

- Spec, path, operation, parameter, response, and schema builders
- Generic JSON serializer for nested alists/lists
- No external dependencies

## Usage

```bash
make test
bash run.sh      # render full OpenAPI spec as JSON
```

## Notes

- Alists (association lists) are CL's lightweight key-value structure.
- `copy-tree` provides deep copy for immutable-style spec updates.
- Keywords (`:foo`) serialize as `"foo"` in JSON output.
