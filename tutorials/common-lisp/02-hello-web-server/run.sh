#!/usr/bin/env bash
set -euo pipefail
echo "Starting web server on :4150 ..."
sbcl --noinform --non-interactive --load src/server.lisp \
     --eval '(hello-web:start-server 4150)'
