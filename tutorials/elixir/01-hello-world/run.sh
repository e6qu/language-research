#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

echo "==> Fetching dependencies..."
mix deps.get

echo "==> Running tests..."
mix test --trace

echo "==> Demo:"
mix run -e 'IO.puts(Hello.greet("Elixir"))'
