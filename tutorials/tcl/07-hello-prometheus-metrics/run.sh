#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

echo "=== Prometheus Metrics E2E Test ==="

OUTPUT=$(tclsh << 'TCL'
source src/metrics.tcl
metrics::counter_inc http_requests_total 42
metrics::histogram_observe request_duration_seconds 0.25
metrics::histogram_observe request_duration_seconds 0.75
puts [metrics::format]
TCL
)

echo "Metrics output:"
echo "$OUTPUT"

echo "$OUTPUT" | grep -q "http_requests_total 42" || { echo "FAIL: missing counter"; exit 1; }
echo "$OUTPUT" | grep -q "request_duration_seconds_sum" || { echo "FAIL: missing histogram sum"; exit 1; }
echo "$OUTPUT" | grep -q "request_duration_seconds_count 2" || { echo "FAIL: missing histogram count"; exit 1; }

echo "=== E2E PASSED ==="
