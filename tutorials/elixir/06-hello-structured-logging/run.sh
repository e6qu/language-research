#!/usr/bin/env bash
set -euo pipefail

echo "==> Fetching dependencies..."
mix deps.get

echo ""
echo "==> Running tests..."
mix test --trace

echo ""
echo "==> Running demo..."
mix run -e 'HelloLogging.demo()'
