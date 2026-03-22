#!/usr/bin/env bash
# Blackbox test for tutorial 06: Structured Logging
# Usage: test-06-logging.sh <tutorial-dir>
#
# Contract: the logger must produce JSON output containing:
#   - "level" field (info, warn, error)
#   - "message" field
#   - valid JSON structure (parseable by python3 json.loads)

set -euo pipefail

DIR="${1:?Usage: $0 <tutorial-dir>}"
cd "$DIR"

echo "  Testing: $(basename $(dirname $PWD))/$(basename $PWD)"

OUTPUT=$(make e2e 2>&1)

if echo "$OUTPUT" | grep -q "E2E: PASS"; then
    echo "  PASS"
    exit 0
else
    echo "  FAIL"
    echo "$OUTPUT" | tail -5
    exit 1
fi
