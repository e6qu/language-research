#!/usr/bin/env bash
set -euo pipefail
lein run "${@:-4101}"
