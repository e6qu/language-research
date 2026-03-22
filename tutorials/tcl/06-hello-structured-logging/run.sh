#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

echo "=== Structured Logging E2E Test ==="

# Generate JSON log and validate with python3 json.load
JSON=$(tclsh << 'TCL'
source src/logger.tcl
puts [logger::info "e2e test" service "myapp" request_id "abc-123"]
TCL
)

echo "Generated JSON: $JSON"

echo "$JSON" | python3 -c "
import sys, json
data = json.load(sys.stdin)
assert 'level' in data, 'missing level'
assert 'message' in data, 'missing message'
assert data['level'] == 'info', f'expected info, got {data[\"level\"]}'
assert data['message'] == 'e2e test', f'expected e2e test, got {data[\"message\"]}'
assert data['service'] == 'myapp', f'expected myapp, got {data[\"service\"]}'
print('JSON validation passed')
"

echo "=== E2E PASSED ==="
