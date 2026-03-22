#!/usr/bin/env bash
set -e

cd "$(dirname "$0")"

echo "==> Running tests..."
npx elm-test

echo ""
echo "==> Compiling Main.elm..."
npx elm make src/Main.elm --output=main.js

echo ""
echo "Done! Open index.html in a browser and check the console for structured log output."
