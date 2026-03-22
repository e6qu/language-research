#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
make build
echo "--- Running hello-web on :3000 ---"
if [ -f build/hello-web ]; then
    ./build/hello-web
fi
