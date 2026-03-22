#!/usr/bin/env bash
set -euo pipefail

echo "Starting server on port 4020..."
tclsh src/server.tcl 4020
