#!/usr/bin/env bash
set -euo pipefail

echo "=== Running tests ==="
busted test/

echo ""
echo "=== Starting server on port 4010 ==="
echo "Press Ctrl+C to stop"
lua src/server.lua 4010
