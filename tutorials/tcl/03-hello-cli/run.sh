#!/usr/bin/env bash
set -euo pipefail

echo "Default:"
tclsh src/hello_cli.tcl

echo "With name:"
tclsh src/hello_cli.tcl --name "Tcl Developer"

echo "With shout:"
tclsh src/hello_cli.tcl --name "Tcl Developer" --shout
