#!/usr/bin/env bash
set -euo pipefail
mvn -q compile exec:java -Dexec.mainClass="hello.Main" -Dexec.args="${1:-4071}"
