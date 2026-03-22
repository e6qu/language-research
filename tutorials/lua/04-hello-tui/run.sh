#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
lua -e 'require("src.tui").run()'
