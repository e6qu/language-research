#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
make build
echo "--- Running hello-logging ---"
if [ -f build/hello-logging ]; then
    ./build/hello-logging
fi
