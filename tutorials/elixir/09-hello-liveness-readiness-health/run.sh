#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

echo "==> Fetching dependencies..."
mix deps.get

echo "==> Running tests..."
mix test --trace

echo "==> Starting server on port 4003..."
mix run --no-halt &
SERVER_PID=$!
sleep 2

echo "==> GET /healthz (liveness)"
curl -s http://localhost:4003/healthz | jq .

echo "==> GET /readyz (readiness)"
curl -s http://localhost:4003/readyz | jq .

echo "==> GET /health (detailed)"
curl -s http://localhost:4003/health | jq .

echo "==> Stopping server..."
kill "$SERVER_PID"
wait "$SERVER_PID" 2>/dev/null || true

echo "Done."
