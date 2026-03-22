#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

echo "==> Fetching dependencies..."
mix deps.get

echo "==> Running tests..."
mix test --trace

echo ""
echo "Demo: run 'mix run -e \"HelloTui.start()\"' to launch the TUI (press q to quit)"
