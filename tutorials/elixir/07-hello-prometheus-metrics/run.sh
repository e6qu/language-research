#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

echo "==> Fetching dependencies..."
mix deps.get

echo "==> Running tests..."
mix test --trace

echo "==> Starting server in background on port 4001..."
elixir --no-halt -S mix &
SERVER_PID=$!
sleep 2

echo "==> Hitting /work 3 times..."
curl -s http://localhost:4001/work | jq .
curl -s http://localhost:4001/work | jq .
curl -s http://localhost:4001/work | jq .

echo ""
echo "==> Scraping /metrics..."
curl -s http://localhost:4001/metrics

echo ""
echo "==> Stopping server (PID $SERVER_PID)..."
kill "$SERVER_PID" 2>/dev/null || true
wait "$SERVER_PID" 2>/dev/null || true

echo "==> Done."
