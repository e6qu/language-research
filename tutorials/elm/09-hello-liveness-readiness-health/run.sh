#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

echo "=== Running tests ==="
npx elm-test

echo ""
echo "=== Building ==="
npx elm make src/Main.elm --output=elm.js

echo ""
echo "Build complete. To run:"
echo "  1. Start your Elixir backend with /healthz, /readyz, and /health endpoints"
echo "  2. Open index.html (or serve it via the backend)"
echo "  3. The dashboard polls every 5 seconds"
