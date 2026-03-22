#!/usr/bin/env bash
set -euo pipefail

echo "=== Running tests ==="
make test

echo ""
echo "=== Running CLI ==="
guile src/hello.scm --name "Scheme"
