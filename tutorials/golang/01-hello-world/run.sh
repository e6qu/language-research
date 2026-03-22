#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

echo "=== Building ==="
go build -o hello ./...

echo "=== Running ==="
./hello

echo "=== Testing ==="
go test -v ./...

echo "=== Done ==="
