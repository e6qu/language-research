#!/usr/bin/env bash
set -euo pipefail
echo "=== 04-hello-tui ==="
make test
make e2e
