#!/usr/bin/env bash
set -euo pipefail
sbcl --noinform --non-interactive --load src/logging.lisp \
     --eval '(let ((l (hello-logging:make-logger :name "demo")))
               (hello-logging:log-info l "Server started" :port 8080)
               (hello-logging:log-warn l "High memory" :usage-pct 85)
               (hello-logging:log-error l "Connection failed" :host "db.local" :retries 3))' \
     --eval '(quit)'
