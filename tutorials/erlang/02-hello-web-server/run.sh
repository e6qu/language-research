#!/usr/bin/env bash
set -euo pipefail

echo "==> Fetching dependencies..."
rebar3 get-deps

echo "==> Compiling..."
rebar3 compile

echo "==> Running tests..."
rebar3 eunit -v

echo ""
echo "All tests passed!"
echo ""
echo "Demo: run 'rebar3 shell' to start the server on port 8080"
echo "  curl http://localhost:8080/"
echo "  curl http://localhost:8080/greet/Erlang"
