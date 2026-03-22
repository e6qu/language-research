#!/usr/bin/env bash
set -euo pipefail

echo "Starting server on port 8080..."
tclsh src/server.tcl 8080
