# 04-hello-tui (Common Lisp)

Terminal UI with ANSI escape codes, raw mode input, and immutable state updates.

## Usage

```bash
make test        # unit tests (no terminal needed)
bash run.sh      # interactive TUI
```

## Keys

- `+` / `-` - increment / decrement counter
- `r` - reset counter
- `q` - quit

## Notes

- `defstruct` with `copy-app-state` gives cheap immutable-style updates.
- `unwind-protect` ensures terminal is restored even on error.
- Raw mode via `/bin/stty` keeps the tutorial dependency-free.
- The condition system could restart on invalid input, but is beyond this scope.
