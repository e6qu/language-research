#!/usr/bin/env bash
set -euo pipefail
echo "=== 09-hello-liveness-readiness-health ==="
make test
make e2e
