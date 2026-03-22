#!/usr/bin/env bash
set -euo pipefail
echo "=== 03-hello-cli ==="
make test
make e2e
