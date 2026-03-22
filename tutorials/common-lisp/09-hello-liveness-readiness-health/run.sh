#!/usr/bin/env bash
set -euo pipefail
echo "Starting health server on :4153 ..."
sbcl --noinform --non-interactive --load src/health.lisp \
     --eval '(hello-health:main)'
