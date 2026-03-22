#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

echo "=== Testing ==="
go test -v ./...

echo "=== Building ==="
go build -o hello ./...

echo "=== Running ==="
./hello
./hello -name Gopher
./hello -name Go -shout
