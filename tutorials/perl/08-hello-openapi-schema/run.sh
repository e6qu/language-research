#!/usr/bin/env bash
set -euo pipefail
echo "=== 08-hello-openapi-schema ==="
make test
make e2e
