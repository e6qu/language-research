#!/usr/bin/env bash
set -euo pipefail

echo "=== Running tests ==="
make test

echo ""
echo "=== Starting metrics server on port 4141 ==="
guile src/hello.scm
