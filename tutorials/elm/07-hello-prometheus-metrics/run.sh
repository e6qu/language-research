#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

echo "==> Compiling Elm..."
elm make src/Main.elm --output=main.js

echo "==> Open index.html in your browser."
echo "    For live metrics, run Elixir tutorial 07 on localhost:4000."
echo ""
echo "==> Running tests..."
elm-test
