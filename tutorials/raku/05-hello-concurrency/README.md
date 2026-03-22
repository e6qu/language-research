# 05-hello-concurrency

Raku concurrency with promises, channels, and a data pipeline.

## Usage

```bash
make build   # syntax check
make test    # run tests
make e2e     # end-to-end check
```

## Structure

- `lib/Concurrent.rakumod` — fetch-all (promises) and pipeline (channels)
- `bin/concurrent.raku` — demo script
- `t/concurrent.rakutest` — unit tests
