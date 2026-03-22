#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

echo "==> Compiling Elm..."
elm make src/Main.elm --output=elm.js

echo "==> Running tests..."
elm-test

echo "==> Done. Open index.html in a browser."
