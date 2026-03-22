(load "src/metrics.lisp")

(in-package :cl-user)

(defvar *tests-passed* 0)
(defvar *tests-failed* 0)

(defmacro test-equal (description expected actual)
  `(if (equal ,expected ,actual)
       (progn (incf *tests-passed*)
              (format t "  PASS: ~A~%" ,description))
       (progn (incf *tests-failed*)
              (format t "  FAIL: ~A~%    expected: ~S~%    actual:   ~S~%"
                      ,description ,expected ,actual))))

(defmacro test-contains (description substring value)
  `(if (search ,substring ,value)
       (progn (incf *tests-passed*)
              (format t "  PASS: ~A~%" ,description))
       (progn (incf *tests-failed*)
              (format t "  FAIL: ~A~%    expected to contain: ~S~%    actual: ~S~%"
                      ,description ,substring ,value))))

(format t "~%Running tests...~%")

;; Counter
(let ((c (hello-metrics:make-counter :name "http_requests_total" :help "Total requests")))
  (hello-metrics:counter-inc c)
  (hello-metrics:counter-inc c 4)
  (test-equal "counter value" 5 (hello-metrics::prom-counter-value c)))

;; Gauge
(let ((g (hello-metrics:make-gauge :name "temperature" :help "Temp")))
  (hello-metrics:gauge-set g 42)
  (test-equal "gauge set" 42 (hello-metrics::prom-gauge-value g))
  (hello-metrics:gauge-inc g 3)
  (test-equal "gauge inc" 45 (hello-metrics::prom-gauge-value g))
  (hello-metrics:gauge-dec g 5)
  (test-equal "gauge dec" 40 (hello-metrics::prom-gauge-value g)))

;; Histogram
(let ((h (hello-metrics:make-histogram :name "request_duration" :help "Duration")))
  (hello-metrics:histogram-observe h 0.1)
  (hello-metrics:histogram-observe h 0.5)
  (hello-metrics:histogram-observe h 1.5)
  (test-equal "histogram count" 3 (hello-metrics::prom-histogram-count h)))

;; Registry + rendering
(let ((reg (hello-metrics:make-registry)))
  (let ((c (hello-metrics:registry-register reg
             (hello-metrics:make-counter :name "requests_total" :help "Total"))))
    (hello-metrics:counter-inc c 10))
  (let ((g (hello-metrics:registry-register reg
             (hello-metrics:make-gauge :name "goroutines" :help "Count"))))
    (hello-metrics:gauge-set g 5))
  (let ((output (hello-metrics:render-metrics reg)))
    (test-contains "counter in output" "# TYPE requests_total counter" output)
    (test-contains "counter value" "requests_total 10" output)
    (test-contains "gauge in output" "# TYPE goroutines gauge" output)
    (test-contains "gauge value" "goroutines 5" output)))

;; Thread-safe counter
(let ((c (hello-metrics:make-counter :name "safe" :help "Thread safe")))
  (let ((threads (loop for i below 10
                       collect (sb-thread:make-thread
                                (lambda ()
                                  (dotimes (j 100)
                                    (hello-metrics:counter-inc c)))))))
    (dolist (th threads) (sb-thread:join-thread th)))
  (test-equal "thread-safe counter" 1000 (hello-metrics::prom-counter-value c)))

(format t "~%~D passed, ~D failed~%" *tests-passed* *tests-failed*)
(when (> *tests-failed* 0) (sb-ext:exit :code 1))
(sb-ext:exit :code 0)
