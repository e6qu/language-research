#!/usr/bin/env bash
set -euo pipefail

echo "=== Building ==="
make build

echo "=== Testing ==="
make test

echo "=== E2E ==="
make e2e

echo "All checks passed."
