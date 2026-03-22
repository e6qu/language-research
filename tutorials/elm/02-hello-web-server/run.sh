#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

echo "==> Running tests..."
elm-test

echo ""
echo "==> Compiling Elm app..."
elm make src/Main.elm --output=main.js

echo ""
echo "Build complete! Open index.html in a browser to run the app."
echo "  open index.html"
