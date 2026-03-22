# 04 - Hello TUI

A minimal terminal UI application using [Ratatouille](https://github.com/ndreynolds/ratatouille), an Elixir library for building terminal apps with the `termbox` rendering backend.

## What you will learn

- Structuring a TUI app with a separate data model and view layer
- Implementing the `Ratatouille.App` behaviour (`init`, `update`, `render`)
- Handling keyboard events to navigate a list
- Writing unit tests for pure model logic

## Project structure

```
lib/
  hello_tui.ex        # App behaviour: init, update, render, start
  hello_tui/model.ex  # Pure data model with cursor navigation
test/
  hello_tui/model_test.exs  # Unit tests for the model
```

## Running

```bash
# Fetch deps and run tests
bash run.sh

# Launch the TUI interactively
mix run -e "HelloTui.start()"
```

Use the arrow keys to move through the list and press `q` to quit.

## Key concepts

**Model** -- A struct holding `items` (a list of strings) and `cursor` (an integer index). All navigation functions are pure: they take a model and return a new model, making them easy to test without a running terminal.

**App behaviour** -- Ratatouille apps implement three callbacks:
- `init/1` -- creates the initial model
- `update/2` -- receives messages (keyboard events) and returns an updated model
- `render/1` -- takes the current model and returns a view tree

This is the same pattern as Elm Architecture / TEA: Model -> Update -> View.
