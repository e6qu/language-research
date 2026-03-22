#!/usr/bin/env bash
set -euo pipefail
echo "=== 05-hello-concurrency ==="
make test
make e2e
