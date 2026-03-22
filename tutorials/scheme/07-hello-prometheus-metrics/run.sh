#!/usr/bin/env bash
set -euo pipefail

echo "=== Running tests ==="
make test

echo ""
echo "=== Starting metrics server on port 8080 ==="
guile src/hello.scm
