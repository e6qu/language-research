#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

echo "=== E2E: Verify build ==="
lua -e 'local s = require("src.tui_state"); local st = s.new(); print(s.selected_item(st))' | grep -q "Lua"
echo "PASS: tui_state module loads and works"

echo "=== E2E: Verify tui module loads ==="
lua -e 'local t = require("src.tui"); print("ok")'  | grep -q "ok"
echo "PASS: tui module loads"

echo "All e2e tests passed."
