#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

echo "=== Running EUnit tests ==="
rebar3 eunit -v

echo ""
echo "=== Tests passed ==="
echo "Demo: rebar3 shell to start server, then curl localhost:8081/metrics"
