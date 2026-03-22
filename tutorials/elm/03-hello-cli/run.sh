#!/usr/bin/env bash
set -e

echo "=== Running tests ==="
npx elm-test

echo ""
echo "=== Building ==="
npx elm make src/Main.elm --output=main.js

echo ""
echo "Build complete. Open index.html in a browser to use the command palette."
