#!/usr/bin/env bash
set -euo pipefail

echo "=== Running EUnit tests ==="
rebar3 eunit -v

echo ""
echo "=== Tests complete ==="
echo ""
echo "Demo: start the server with:"
echo "  rebar3 shell"
echo ""
echo "Then test the endpoints:"
echo "  curl localhost:8083/healthz"
echo "  curl localhost:8083/readyz"
echo "  curl localhost:8083/health"
