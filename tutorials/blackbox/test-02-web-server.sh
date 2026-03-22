#!/usr/bin/env bash
# Blackbox test for tutorial 02: Web Server
# Usage: test-02-web-server.sh <tutorial-dir> <port>
#
# Contract: the web server must expose:
#   GET /           -> 200, JSON body containing "Hello, world!"
#   GET /greet/Test -> 200, JSON body containing "Hello, Test!"
#   GET /nonexistent -> 404
#
# The Makefile's e2e target handles starting/stopping the server.

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
