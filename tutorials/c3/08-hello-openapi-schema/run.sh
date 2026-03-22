#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
make build
echo "--- Running hello-openapi ---"
if [ -f build/hello-openapi ]; then
    ./build/hello-openapi
fi
