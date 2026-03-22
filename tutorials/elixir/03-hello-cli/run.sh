#!/usr/bin/env bash
set -euo pipefail

echo "==> Fetching deps..."
mix deps.get

echo "==> Running tests..."
mix test --trace

echo "==> Building escript..."
mix escript.build

echo "==> Demo run:"
./hello_cli --name Elixir --shout
