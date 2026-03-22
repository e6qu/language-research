#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

echo "=== Fetching dependencies ==="
mix deps.get

echo ""
echo "=== Running tests ==="
mix test --trace

echo ""
echo "=== Starting server on port 4002 ==="
mix run --no-halt &
SERVER_PID=$!
sleep 2

echo ""
echo "=== GET /api/openapi ==="
curl -s http://localhost:4002/api/openapi | jq .

echo ""
echo "=== GET /api/greet?name=Elixir ==="
curl -s "http://localhost:4002/api/greet?name=Elixir" | jq .

echo ""
echo "=== GET /api/greet (no name, expect 400) ==="
curl -s -w "\nHTTP status: %{http_code}\n" http://localhost:4002/api/greet | jq .

kill $SERVER_PID 2>/dev/null || true
echo ""
echo "=== Done ==="
