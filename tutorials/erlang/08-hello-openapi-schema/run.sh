#!/usr/bin/env bash
set -e

echo "=== Running EUnit tests ==="
rebar3 eunit -v

echo ""
echo "=== Tests passed ==="
echo ""
echo "Demo: start the server with:"
echo "  rebar3 shell"
echo ""
echo "Then in another terminal:"
echo "  curl localhost:8082/api/openapi | jq"
echo "  curl 'localhost:8082/api/greet?name=World' | jq"
echo "  curl localhost:8082/api/greet | jq"
