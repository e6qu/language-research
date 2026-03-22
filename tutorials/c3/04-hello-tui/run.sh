#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
make build
echo "--- Running hello-tui ---"
if [ -f build/hello-tui ]; then
    ./build/hello-tui C3
fi
