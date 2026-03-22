#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

echo "==> Running tests..."
elm-test

echo "==> Compiling..."
elm make src/Main.elm --output=main.js

echo "==> Done! Open index.html in a browser."
echo "    Arrow keys to move cursor, type to write characters."
