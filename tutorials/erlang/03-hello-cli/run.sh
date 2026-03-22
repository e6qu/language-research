#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

echo "=== Running tests ==="
rebar3 eunit -v

echo ""
echo "=== Building and running escript ==="
rebar3 escriptize && _build/default/bin/hello_cli --name Erlang --shout
