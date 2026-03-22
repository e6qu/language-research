# 05 - Hello Concurrency

A minimal Elixir tutorial demonstrating concurrent HTTP fetching with `Task.async_stream` and Erlang's `:httpc`.

## What it covers

- **`:httpc`** — Erlang's built-in HTTP client (no external deps needed)
- **`Task.async_stream/3`** — runs work across a pool of concurrent tasks
- **SSL configuration** — using OTP 25+ `cacerts_get()` for certificate verification

## Key files

| File | Purpose |
|------|---------|
| `lib/hello_concurrency.ex` | `fetch/1` wraps `:httpc`, `fetch_all/1` parallelizes with `Task.async_stream` |
| `test/hello_concurrency_test.exs` | Tests for empty list, valid URL, invalid URL, and multi-URL fetch |

## Running

```bash
chmod +x run.sh && ./run.sh
```

Or step by step:

```bash
mix deps.get
mix test --trace
mix run -e 'HelloConcurrency.demo()'
```

## How it works

1. `fetch/1` converts the URL to a charlist and calls `:httpc.request/4`, returning `{:ok, status_code}` or `{:error, reason}`.
2. `fetch_all/1` pipes a list of URLs through `Task.async_stream`, fetching up to 5 URLs concurrently, and collects `{url, result}` tuples.
3. `:inets` and `:ssl` are listed in `extra_applications` in `mix.exs` so they start automatically with the app.
