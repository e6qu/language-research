#!/usr/bin/env bash
set -euo pipefail
echo "=== 06-hello-structured-logging ==="
make test
make e2e
