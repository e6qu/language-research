# 05-hello-concurrency

Cooperative concurrent URL fetching using Lua 5.4 coroutines.

## Overview

Demonstrates Lua coroutines with a simulated concurrent URL fetcher. Each fetch is a coroutine that yields during its "network" phase, and a round-robin scheduler resumes them cooperatively.

## Structure

- `src/concurrent.lua` - Coroutine-based fetcher and round-robin scheduler
- `test/concurrent_test.lua` - Unit tests
- `e2e/e2e_test.sh` - End-to-end verification

## Usage

```bash
make deps       # Install busted via luarocks
make test       # Run unit tests
make e2e        # Run e2e tests
bash run.sh     # Run the demo
```
