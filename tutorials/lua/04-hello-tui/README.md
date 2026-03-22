# 04-hello-tui

ANSI escape code TUI with a selectable list in plain Lua 5.4.

## Overview

A terminal UI that displays a list of programming languages. Navigate with arrow keys and press `q` to quit. Uses ANSI escape codes for rendering and `stty` for raw terminal input.

## Structure

- `src/tui_state.lua` - State management (items, cursor, movement)
- `src/tui.lua` - Terminal rendering and input loop
- `test/tui_state_test.lua` - Unit tests for state logic
- `e2e/e2e_test.sh` - Build verification (interactive app not tested in e2e)

## Usage

```bash
make deps       # Install busted via luarocks
make test       # Run unit tests
make e2e        # Run e2e verification
bash run.sh     # Launch the interactive TUI
```

## Controls

- Up/Down arrows: move selection
- q: quit and print selected item
