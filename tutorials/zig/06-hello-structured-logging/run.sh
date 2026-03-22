#!/usr/bin/env bash
set -euo pipefail
zig build
./zig-out/bin/hello-structured-logging
