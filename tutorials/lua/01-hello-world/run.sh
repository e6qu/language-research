#!/usr/bin/env bash
set -euo pipefail

echo "=== Running tests ==="
busted test/

echo ""
echo "=== Running hello ==="
lua -e 'h=require("src.hello"); print(h.greet("Lua"))'
