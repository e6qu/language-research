#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

echo "=== Running EUnit tests ==="
rebar3 eunit -v

echo ""
echo "=== Running demo ==="
rebar3 shell --config config/sys.config -eval 'hello_logging:demo(), halt().'
