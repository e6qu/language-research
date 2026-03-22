#!/usr/bin/env bash
set -euo pipefail
echo "=== 01-hello-world ==="
make test
make e2e
