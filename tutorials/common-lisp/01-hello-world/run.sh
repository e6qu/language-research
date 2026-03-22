#!/usr/bin/env bash
set -euo pipefail
sbcl --noinform --non-interactive --load src/hello.lisp \
     --eval '(format t "~A~%" (hello:greet))' \
     --eval '(quit)'
