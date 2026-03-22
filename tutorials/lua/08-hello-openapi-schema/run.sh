#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

echo "=== OpenAPI Schema Demo ==="
lua -e '
local spec = require("src.openapi_spec")

print("--- OpenAPI JSON Spec ---")
print(spec.to_json())

print()
print("--- Validate name ---")
local name, err = spec.validate_name("World")
if name then
    print("Valid: " .. name)
end

local name2, err2 = spec.validate_name(nil)
if not name2 then
    print("Invalid: " .. err2)
end
'
