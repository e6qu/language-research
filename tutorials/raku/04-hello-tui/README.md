# 04-hello-tui

Immutable TUI state model in Raku using a class with functional updates.

## Usage

```bash
make build   # syntax check
make test    # run tests
make e2e     # verify output
```

## Structure

- `lib/TuiState.rakumod` — immutable state class with cursor navigation
- `bin/tui.raku` — demo script
- `t/tui_state.rakutest` — unit tests
