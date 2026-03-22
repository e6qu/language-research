#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
eval $(luarocks path --bin 2>/dev/null) || true
lua -e '
local logger = require("src.logger")
print(logger.info("Application started", {version = "1.0.0"}))
print(logger.warn("Disk space low", {percent_free = 5}))
print(logger.error("Connection failed", {host = "db.example.com", retries = 3}))
'
