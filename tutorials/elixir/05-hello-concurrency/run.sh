#!/usr/bin/env bash
set -euo pipefail

echo "==> Getting dependencies..."
mix deps.get

echo "==> Running tests..."
mix test --trace

echo "==> Running demo..."
mix run -e 'HelloConcurrency.demo()'
