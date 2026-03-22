#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

echo "=== Liveness / Readiness / Health Demo ==="
lua -e '
local h = require("src.health_checker")
h.init()

print("--- Liveness ---")
print(h.liveness_json())

print()
print("--- Readiness (healthy) ---")
local body, code = h.readiness_json()
print(string.format("HTTP %d: %s", code, body))

print()
h.set_dependency("database", "error")
print("--- Readiness (degraded) ---")
body, code = h.readiness_json()
print(string.format("HTTP %d: %s", code, body))

print()
print("--- Health ---")
print(h.health_json())
'
