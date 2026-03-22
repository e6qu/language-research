# 01 - Hello World

Your first Elixir module: define functions, use string interpolation, and run tests with ExUnit.

## Prerequisites

- Elixir >= 1.16

## What You Learn

- Creating a Mix project
- Defining a module with public functions
- String interpolation with `#{}`
- Writing and running ExUnit tests

## Step by Step

1. **mix.exs** declares the project (`:hello`, Elixir ~> 1.16, no dependencies).
2. **lib/hello.ex** defines `Hello.greet/0` (returns `"Hello, world!"`) and `Hello.greet/1` (returns `"Hello, <name>!"`).
3. **test/hello_test.exs** verifies both functions with three test cases.

## Run Tests

```bash
# Quick start (fetch deps, test, demo):
./run.sh

# Or manually:
mix deps.get
mix test --trace
```

## Exercises

1. Add a `greet/2` function that accepts a greeting word: `Hello.greet("Hi", "Alice")` returns `"Hi, Alice!"`.
2. Write a test that verifies `greet/1` with a multi-word name like `"Ada Lovelace"`.
3. Add a `farewell/1` function that returns `"Goodbye, <name>!"` and test it.
