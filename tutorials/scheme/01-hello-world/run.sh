#!/usr/bin/env bash
set -euo pipefail

echo "=== Running tests ==="
make test

echo ""
echo "=== Running hello ==="
guile -c '(load "src/hello.scm") (display (greet "Scheme")) (newline)'
