(use-modules (srfi srfi-64))

(load "../src/hello.scm")

(test-begin "prometheus-metrics")

;; Reset between tests
(metrics-reset!)

(let ((c (make-counter "test_total" "A test counter")))
  (test-equal "counter starts at 0" 0 (metric-value "test_total"))
  (counter-inc! "test_total")
  (test-equal "counter incremented" 1 (metric-value "test_total"))
  (counter-inc! "test_total" 5)
  (test-equal "counter inc by 5" 6 (metric-value "test_total")))

(metrics-reset!)

(let ((g (make-gauge "test_gauge" "A test gauge")))
  (test-equal "gauge starts at 0" 0 (metric-value "test_gauge"))
  (gauge-set! "test_gauge" 42)
  (test-equal "gauge set" 42 (metric-value "test_gauge"))
  (gauge-inc! "test_gauge" 8)
  (test-equal "gauge inc" 50 (metric-value "test_gauge")))

(metrics-reset!)

(make-counter "req_total" "Requests")
(counter-inc! "req_total" 10)
(let ((output (metrics->prometheus)))
  (test-assert "prometheus format has HELP"
    (string-contains output "# HELP req_total"))
  (test-assert "prometheus format has TYPE"
    (string-contains output "# TYPE req_total counter"))
  (test-assert "prometheus format has value"
    (string-contains output "req_total 10")))

(test-end "prometheus-metrics")
