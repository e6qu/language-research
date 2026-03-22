#!/usr/bin/env bash
set -euo pipefail
sbcl --noinform --non-interactive --load src/metrics.lisp \
     --eval '(let* ((reg (hello-metrics:make-registry))
                    (c (hello-metrics:registry-register reg
                         (hello-metrics:make-counter :name "http_requests_total"
                                                     :help "Total HTTP requests")))
                    (g (hello-metrics:registry-register reg
                         (hello-metrics:make-gauge :name "active_connections"
                                                   :help "Current connections")))
                    (h (hello-metrics:registry-register reg
                         (hello-metrics:make-histogram :name "request_duration_seconds"
                                                       :help "Request latency"))))
               (hello-metrics:counter-inc c 150)
               (hello-metrics:gauge-set g 23)
               (hello-metrics:histogram-observe h 0.05)
               (hello-metrics:histogram-observe h 0.2)
               (hello-metrics:histogram-observe h 1.3)
               (format t "~A" (hello-metrics:render-metrics reg)))' \
     --eval '(quit)'
