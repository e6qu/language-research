# 06 — Hello Structured Logging

Emit JSON-structured logs from an Elixir application using
[LoggerJSON](https://hex.pm/packages/logger_json) v7+.

## What you will learn

- Configuring Elixir's built-in `Logger` with a custom formatter
- Attaching metadata (key-value pairs) to log lines
- Verifying JSON log output in tests with `ExUnit.CaptureLog`

## Key files

| File | Purpose |
|---|---|
| `config/config.exs` | Wires `LoggerJSON.Formatters.Basic` into the `:default_handler` |
| `lib/hello_logging.ex` | `HelloLogging.demo/0` — logs at info, warning, and error levels |
| `test/hello_logging_test.exs` | Captures log output, parses JSON, asserts on structure |

## Quick start

```bash
chmod +x run.sh
./run.sh
```

This fetches deps, runs the test suite, then executes the demo which prints
three structured JSON log lines to stdout.

## How it works

Elixir 1.15+ exposes a formatter API on the default Erlang logger handler.
LoggerJSON v7 plugs into that API so every `Logger.info/2` call (and friends)
produces a single JSON object per line instead of plain text.

The config is two lines:

```elixir
config :logger, :default_handler,
  formatter: {LoggerJSON.Formatters.Basic, []}
```

Metadata passed as the second argument to any `Logger.*` call lands in the
JSON output, making logs easy to search and filter in any log aggregator.
