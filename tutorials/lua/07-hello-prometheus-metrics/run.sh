#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

echo "=== Prometheus Metrics Demo ==="
lua -e '
local m = require("src.metrics")

m.counter_inc("http_requests_total")
m.counter_inc("http_requests_total")
m.counter_inc("http_requests_total")
m.counter_inc("http_errors_total")

m.histogram_observe("request_duration_seconds", 0.12)
m.histogram_observe("request_duration_seconds", 0.45)
m.histogram_observe("request_duration_seconds", 0.03)

print("--- Prometheus Text Format ---")
print(m.format())
'
