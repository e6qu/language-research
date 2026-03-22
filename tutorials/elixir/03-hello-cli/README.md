# 03 - Hello CLI

Build a command-line executable with Elixir's `escript` and `OptionParser`.

## What you'll learn

- Defining an escript entry point (`main/1`)
- Parsing flags with `OptionParser`
- Building a self-contained CLI binary

## Project structure

```
mix.exs              # project config with escript setting
lib/hello_cli.ex     # CLI module: arg parsing, formatting, output
test/hello_cli_test.exs  # unit tests
```

## Key concepts

**escript** compiles your project into a single executable that runs on any
machine with Erlang installed. The `main/1` function receives `argv` as a list
of strings.

**OptionParser.parse/2** handles `--name <value>` (string) and `--shout`
(boolean) flags, returning parsed keyword opts alongside any remaining args.

## Run it

```bash
chmod +x run.sh
./run.sh
```

This fetches deps, runs the tests, builds the escript, and runs:

```
./hello_cli --name Elixir --shout
# => HELLO, ELIXIR!
```
