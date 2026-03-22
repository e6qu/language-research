#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

echo "=== E2E: logger.info produces valid JSON ==="
eval $(luarocks path --bin 2>/dev/null) || true
lua -e 'l=require("src.logger"); print(l.info("test"))' | python3 -c "import sys,json; json.load(sys.stdin)"
echo "PASS: output is valid JSON"

echo "=== E2E: logger.error produces valid JSON with level ==="
lua -e 'l=require("src.logger"); print(l.error("boom", {code=500}))' | python3 -c "
import sys, json
d = json.load(sys.stdin)
assert d['level'] == 'error', 'wrong level'
assert d['code'] == 500, 'missing metadata'
"
echo "PASS: error level and metadata correct"

echo "All e2e tests passed."
