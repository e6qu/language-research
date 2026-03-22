#!/usr/bin/env bash
# Blackbox test for tutorial 07: Prometheus Metrics
# Usage: test-07-metrics.sh <tutorial-dir> <port>
#
# Contract: the metrics server must expose:
#   GET /metrics -> text/plain containing Prometheus format metrics
#   After hitting a work endpoint, counter metrics must increment

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
