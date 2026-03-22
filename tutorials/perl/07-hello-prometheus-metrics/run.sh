#!/usr/bin/env bash
set -euo pipefail
echo "=== 07-hello-prometheus-metrics ==="
make test
make e2e
