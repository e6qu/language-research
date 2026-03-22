# 05 - Hello Concurrency

Parallel HTTP fetching with Erlang lightweight processes.

## Run

```bash
chmod +x run.sh
./run.sh
```

## What it demonstrates

- Spawning processes with `spawn/1`
- Message passing with `!` and `receive`
- Using `make_ref()` to correlate responses
- Timeout handling in `receive` blocks
- `httpc` for HTTP requests
