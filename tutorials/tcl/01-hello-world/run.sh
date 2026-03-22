#!/usr/bin/env bash
set -euo pipefail

tclsh << 'EOF'
source src/hello.tcl
puts [hello::greet]
puts [hello::greet "Tcl Developer"]
EOF
