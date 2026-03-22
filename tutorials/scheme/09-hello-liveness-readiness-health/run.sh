#!/usr/bin/env bash
set -euo pipefail

echo "=== Running tests ==="
make test

echo ""
echo "=== Starting health server on port 4143 ==="
guile src/hello.scm
