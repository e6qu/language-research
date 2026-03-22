#!/usr/bin/env bash
set -euo pipefail
echo "=== 02-hello-web-server ==="
make test
make e2e
