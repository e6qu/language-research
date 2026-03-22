#!/usr/bin/env bash
# Blackbox test for tutorial 09: Health Checks
# Usage: test-09-health.sh <tutorial-dir> <port>
#
# Contract: the server must expose:
#   GET /healthz -> 200, JSON with "status" field
#   GET /readyz  -> 200 when healthy, 503 when degraded
#   GET /health  -> 200, JSON with dependency check details

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
