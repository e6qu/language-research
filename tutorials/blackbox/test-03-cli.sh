#!/usr/bin/env bash
# Blackbox test for tutorial 03: CLI
# Usage: test-03-cli.sh <tutorial-dir>
#
# Contract: the CLI must support:
#   --name <name>  -> "Hello, <name>!"
#   --shout        -> uppercase output
#   --name Test --shout -> "HELLO, TEST!"

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
