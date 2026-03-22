# 01-hello-world

A minimal Lua module that returns a greeting string.

## Prerequisites

- Lua 5.4
- busted (`luarocks install busted`)

## Files

- `src/hello.lua` — greeting module with `greet(name)` function
- `test/hello_test.lua` — unit tests using busted

## Usage

```bash
# Run tests
make test

# Run end-to-end check
make e2e

# Run everything
bash run.sh
```

## API

- `hello.greet()` — returns `"Hello, world!"`
- `hello.greet("Alice")` — returns `"Hello, Alice!"`
- `hello.greet("")` — returns `"Hello, world!"`
