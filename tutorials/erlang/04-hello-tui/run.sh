#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

echo "=== Running tests ==="
rebar3 eunit -v

echo ""
echo "=== Tests passed ==="
echo "Demo: rebar3 eval 'hello_tui:start().' (press q to quit)"
