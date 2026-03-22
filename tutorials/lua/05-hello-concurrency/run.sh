#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
lua -e '
local c = require("src.concurrent")
local urls = {"http://example.com/a", "http://example.com/b", "http://example.com/c"}
print("Fetching " .. #urls .. " URLs with coroutines...")
local results = c.fetch_all(urls)
for _, r in ipairs(results) do
    print("  " .. r.url .. " -> status " .. r.status)
end
print("Done. Got " .. #results .. " results.")
'
