#!/usr/bin/env bash
# Blackbox test for tutorial 05: Concurrency
# Usage: test-05-concurrency.sh <tutorial-dir>
#
# Contract: the program must demonstrate concurrent execution.
# Verified via unit tests that check:
#   - Empty input returns empty results
#   - Multiple inputs are processed (all return results)
#   - Results arrive for each input

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
