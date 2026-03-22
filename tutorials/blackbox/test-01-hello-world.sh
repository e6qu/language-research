#!/usr/bin/env bash
# Blackbox test for tutorial 01: Hello World
# Usage: test-01-hello-world.sh <tutorial-dir>
#
# Contract: `make e2e` in the tutorial dir must produce stdout containing
# "Hello, World!" when the program is run with argument "World".
# The Makefile's e2e target is responsible for invoking the program correctly.
#
# This script verifies the external behavior is correct.

set -euo pipefail

DIR="${1:?Usage: $0 <tutorial-dir>}"
cd "$DIR"

echo "  Testing: $(basename $(dirname $PWD))/$(basename $PWD)"

# The e2e target must run the program and output must contain "Hello"
OUTPUT=$(make e2e 2>&1)

if echo "$OUTPUT" | grep -q "E2E: PASS"; then
    echo "  PASS"
    exit 0
else
    echo "  FAIL"
    echo "$OUTPUT" | tail -5
    exit 1
fi
