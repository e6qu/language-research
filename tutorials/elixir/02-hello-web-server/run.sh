#!/usr/bin/env bash
set -e

echo "==> Fetching dependencies..."
mix deps.get

echo "==> Running tests..."
mix test --trace

echo "==> Starting server in background..."
elixir --no-halt -S mix &
SERVER_PID=$!
sleep 2

echo "==> GET /"
curl -s http://localhost:4000/
echo

echo "==> GET /greet/Elixir"
curl -s http://localhost:4000/greet/Elixir
echo

echo "==> Stopping server..."
kill $SERVER_PID
