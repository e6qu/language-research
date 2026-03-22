#!/usr/bin/env bash
set -euo pipefail
echo "=== Running tests ==="
elm-test
echo ""
echo "=== Demo ==="
elm make src/Main.elm --output=main.js
echo "Built main.js — open index.html in a browser to see the app"
