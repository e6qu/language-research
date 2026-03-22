# 03-hello-cli

Erlang CLI application using `argparse` (OTP 26+) and `escript`.

## What it covers

- Argument parsing with `argparse:parse/2`
- Escript entry point (`main/1`)
- Pattern matching on maps
- EUnit tests

## Usage

```sh
# Run tests and build/run the escript
bash run.sh

# Or manually
rebar3 escriptize
_build/default/bin/hello_cli --name World
_build/default/bin/hello_cli --name World --shout
```
