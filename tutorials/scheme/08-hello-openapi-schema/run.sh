#!/usr/bin/env bash
set -euo pipefail

echo "=== Running tests ==="
make test

echo ""
echo "=== OpenAPI spec output ==="
guile src/hello.scm
