#!/usr/bin/env bash
set -euo pipefail
sbcl --noinform --non-interactive --load src/tui.lisp \
     --eval '(hello-tui:main)'
