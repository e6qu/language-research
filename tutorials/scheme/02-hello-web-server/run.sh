#!/usr/bin/env bash
set -euo pipefail

echo "=== Running tests ==="
make test

echo ""
echo "=== Starting server on port 4140 ==="
guile src/hello.scm
