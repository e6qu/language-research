#!/usr/bin/env bash
set -euo pipefail
sbcl --noinform --non-interactive --load src/concurrency.lisp \
     --eval '(hello-concurrency:main)' \
     --eval '(quit)'
