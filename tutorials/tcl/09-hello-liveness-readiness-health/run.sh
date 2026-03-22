#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

echo "=== Liveness/Readiness/Health E2E Test ==="

OUTPUT=$(tclsh << 'TCL'
source src/health_checker.tcl
health_checker::init
puts "LIVENESS: [health_checker::liveness_json]"
puts "HEALTH: [health_checker::health_json]"
puts "STATUS: [health_checker::status]"
TCL
)

echo "$OUTPUT"

echo "$OUTPUT" | grep -q '"status":"ok"' || { echo "FAIL: missing ok status"; exit 1; }
echo "$OUTPUT" | grep -q "LIVENESS:" || { echo "FAIL: missing liveness output"; exit 1; }
echo "$OUTPUT" | grep -q "HEALTH:" || { echo "FAIL: missing health output"; exit 1; }

echo "=== E2E PASSED ==="
