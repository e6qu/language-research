# 01 - Hello World (Erlang)

A minimal Erlang project using Rebar3.

## Prerequisites

- Erlang/OTP >= 26
- Rebar3

## What You Learn

- Basic Rebar3 project structure
- Writing and exporting Erlang functions
- Binary string handling
- EUnit testing

## Steps

1. **Review the code** in `src/hello.erl` -- a module with two functions: `greet/0` returns a default greeting, `greet/1` accepts a binary name.
2. **Run the tests**: `rebar3 eunit -v`
3. **Try it interactively**: `rebar3 shell` then call `hello:greet(<<"World">>).`
4. **Or run everything at once**: `./run.sh`

## Exercises

1. Add a `greet/2` function that takes a greeting and a name (e.g., `greet(<<"Hi">>, <<"Bob">>)` returns `<<"Hi, Bob!">>`).
2. Add a test for non-ASCII names.
3. Create a `farewell/1` function and corresponding tests.
