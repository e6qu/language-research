#!/usr/bin/env bash
set -euo pipefail
echo "=== Running tests ==="
rebar3 eunit -v
echo ""
echo "=== Demo ==="
rebar3 eval 'io:format("~s~n", [hello:greet(<<"Erlang">>)]).'
