#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

echo "=== E2E: fetch_all returns correct count ==="
lua -e 'c=require("src.concurrent"); r=c.fetch_all({"a","b"}); print(#r)' | grep -q "2"
echo "PASS: fetch_all returned 2 results"

echo "=== E2E: results contain url field ==="
lua -e 'c=require("src.concurrent"); r=c.fetch_all({"http://x"}); print(r[1].url)' | grep -q "http://x"
echo "PASS: result contains correct url"

echo "All e2e tests passed."
