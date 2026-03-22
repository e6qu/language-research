# 06-hello-structured-logging (Common Lisp)

JSON structured logging with level filtering, no external dependencies.

## Features

- JSON output built with `format` and string operations
- Log levels: debug, info, warn, error
- Dynamic `*log-level*` filtering via special variables
- Extra fields via keyword arguments

## Usage

```bash
make test
bash run.sh      # demo output
```

## Example output

```json
{"timestamp":"2026-03-22T10:30:00Z","level":"info","logger":"demo","message":"Server started","port":8080}
```

## Notes

- Special variables (`defvar`/`defparameter`) with earmuffs (`*name*`) are CL's dynamic variables.
- They can be rebound per-thread with `let`, making them natural for context-local config.
- The condition system could log conditions with full stack context, but is beyond this scope.
