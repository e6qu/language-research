#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
wasm-pack build --target web
echo "Build complete. Serve with: python3 -m http.server 8080"
