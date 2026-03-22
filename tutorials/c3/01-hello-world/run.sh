#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
make build
echo "--- Running hello ---"
if [ -f build/hello ]; then
    ./build/hello
    ./build/hello C3
fi
