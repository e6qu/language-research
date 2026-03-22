#!/usr/bin/env bash
set -euo pipefail

echo "=== Running tests ==="
busted test/

echo ""
echo "=== Running CLI examples ==="
echo "Default:"
lua src/hello_cli.lua

echo "With --name:"
lua src/hello_cli.lua --name Lua

echo "With --shout:"
lua src/hello_cli.lua --name Lua --shout
