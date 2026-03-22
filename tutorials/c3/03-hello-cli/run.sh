#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
make build
echo "--- Running hello-cli ---"
if [ -f build/hello-cli ]; then
    ./build/hello-cli
    ./build/hello-cli --name C3
    ./build/hello-cli --name C3 --shout
fi
