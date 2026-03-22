#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
make build
echo "--- Running hello-metrics ---"
if [ -f build/hello-metrics ]; then
    ./build/hello-metrics
fi
