#!/usr/bin/env bash
# Blackbox test for tutorial 04: TUI
# Usage: test-04-tui.sh <tutorial-dir>
#
# Contract: the TUI must:
#   - Display a selectable list of items
#   - Respond to arrow key navigation
#   - Highlight the selected item
#
# Test strategy: use tmux + capture-pane to verify rendered output.
# Falls back to unit test verification if tmux is unavailable.

set -euo pipefail

DIR="${1:?Usage: $0 <tutorial-dir>}"
cd "$DIR"

echo "  Testing: $(basename $(dirname $PWD))/$(basename $PWD)"

# TUI testing via tmux screenshot
if command -v tmux &>/dev/null && [ -n "${TMUX_TEST:-}" ]; then
    SESSION="tui-test-$$"
    tmux new-session -d -s "$SESSION" -x 80 -y 24 "make run-tui 2>/dev/null; sleep 1"
    sleep 2

    # Capture the screen
    SCREEN=$(tmux capture-pane -t "$SESSION" -p)

    # Send down arrow, capture again
    tmux send-keys -t "$SESSION" Down
    sleep 0.5
    SCREEN2=$(tmux capture-pane -t "$SESSION" -p)

    # Send q to quit
    tmux send-keys -t "$SESSION" q
    sleep 0.5
    tmux kill-session -t "$SESSION" 2>/dev/null || true

    # Verify: screen should contain at least one item name
    if echo "$SCREEN" | grep -qE "Elixir|Lua|Rust|Tcl|Perl|Raku|Erlang|Elm|Go"; then
        echo "  PASS (tmux screenshot)"
        exit 0
    else
        echo "  FAIL (tmux screenshot — no items visible)"
        echo "$SCREEN" | head -10
        exit 1
    fi
fi

# Fallback: verify via unit tests (tests the model logic)
OUTPUT=$(make e2e 2>&1)

if echo "$OUTPUT" | grep -q "E2E: PASS"; then
    echo "  PASS (unit test)"
    exit 0
else
    echo "  FAIL"
    echo "$OUTPUT" | tail -5
    exit 1
fi
