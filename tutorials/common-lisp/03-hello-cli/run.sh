#!/usr/bin/env bash
set -euo pipefail
sbcl --noinform --non-interactive --load src/cli.lisp \
     --eval '(hello-cli:main)'
