#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
make build
echo "--- Running hello-concurrency ---"
if [ -f build/hello-concurrency ]; then
    ./build/hello-concurrency
fi
