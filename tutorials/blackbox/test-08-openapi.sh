#!/usr/bin/env bash
# Blackbox test for tutorial 08: OpenAPI Schema
# Usage: test-08-openapi.sh <tutorial-dir> <port>
#
# Contract: the server must expose:
#   GET /api/openapi -> JSON containing "openapi" key with version "3.0.x"
#   The spec must contain at least one path definition

set -euo pipefail

DIR="${1:?Usage: $0 <tutorial-dir> <port>}"
PORT="${2:?Usage: $0 <tutorial-dir> <port>}"
cd "$DIR"

echo "  Testing: $(basename $(dirname $PWD))/$(basename $PWD) on port $PORT"

OUTPUT=$(make e2e 2>&1)

if echo "$OUTPUT" | grep -q "E2E: PASS"; then
    echo "  PASS"
    exit 0
else
    echo "  FAIL"
    echo "$OUTPUT" | tail -5
    exit 1
fi
