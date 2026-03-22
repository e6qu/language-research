# 03-hello-cli

A minimal Lua CLI tool with argument parsing.

## Prerequisites

- Lua 5.4
- busted (`luarocks install busted`)

## Files

- `src/hello_cli.lua` — CLI tool with `--name` and `--shout` flags
- `test/hello_cli_test.lua` — unit tests for argument parsing and formatting

## Usage

```bash
# Run tests
make test

# Run end-to-end check
make e2e

# Run the CLI
lua src/hello_cli.lua
lua src/hello_cli.lua --name Alice
lua src/hello_cli.lua --name Alice --shout

# Run all examples
bash run.sh
```

## Options

- `--name NAME` — name to greet (default: `world`)
- `--shout` — output greeting in uppercase
