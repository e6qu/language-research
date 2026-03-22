#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

echo "=== OpenAPI Schema E2E Test ==="

OUTPUT=$(tclsh << 'TCL'
source src/openapi_spec.tcl
puts [openapi_spec::spec_json]
TCL
)

echo "Spec JSON: $OUTPUT"

echo "$OUTPUT" | grep -q "openapi" || { echo "FAIL: missing openapi key"; exit 1; }
echo "$OUTPUT" | grep -q "3.0.0" || { echo "FAIL: missing version 3.0.0"; exit 1; }
echo "$OUTPUT" | grep -q "/api/greet" || { echo "FAIL: missing /api/greet path"; exit 1; }

echo "=== E2E PASSED ==="
