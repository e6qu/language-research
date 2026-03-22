#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
make build
echo "--- Running hello-health on :3000 ---"
if [ -f build/hello-health ]; then
    ./build/hello-health
fi
