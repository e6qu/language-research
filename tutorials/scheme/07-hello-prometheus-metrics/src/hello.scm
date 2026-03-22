(use-modules (ice-9 hash-table)
             (web server)
             (web request)
             (web response)
             (web uri))

;; Metrics registry: hash of name -> (type help value)
(define *metrics* (make-hash-table))

(define (make-counter name help)
  (hash-set! *metrics* name (list "counter" help 0))
  name)

(define (make-gauge name help)
  (hash-set! *metrics* name (list "gauge" help 0))
  name)

(define (counter-inc! name . args)
  (let* ((entry (hash-ref *metrics* name))
         (delta (if (pair? args) (car args) 1)))
    (hash-set! *metrics* name
               (list (car entry) (cadr entry) (+ (caddr entry) delta)))))

(define (gauge-set! name value)
  (let ((entry (hash-ref *metrics* name)))
    (hash-set! *metrics* name
               (list (car entry) (cadr entry) value))))

(define (gauge-inc! name . args)
  (let* ((entry (hash-ref *metrics* name))
         (delta (if (pair? args) (car args) 1)))
    (hash-set! *metrics* name
               (list (car entry) (cadr entry) (+ (caddr entry) delta)))))

(define (metric-value name)
  (let ((entry (hash-ref *metrics* name)))
    (if entry (caddr entry) #f)))

(define (metrics-reset!)
  (hash-clear! *metrics*))

(define (format-metric name entry)
  (let ((type (car entry))
        (help (cadr entry))
        (value (caddr entry)))
    (string-append
     "# HELP " name " " help "\n"
     "# TYPE " name " " type "\n"
     name " " (number->string value) "\n")))

(define (metrics->prometheus)
  "Format all metrics in Prometheus exposition format."
  (let ((lines '()))
    (hash-for-each
     (lambda (name entry)
       (set! lines (cons (format-metric name entry) lines)))
     *metrics*)
    (string-join (sort lines string<?) "")))

;; Set up default metrics
(define (setup-default-metrics)
  (make-counter "http_requests_total" "Total HTTP requests")
  (make-gauge "app_uptime_seconds" "Application uptime in seconds"))

;; HTTP handler
(define (request-path request)
  (uri-path (request-uri request)))

(define (handler request body)
  (counter-inc! "http_requests_total")
  (let ((path (request-path request)))
    (cond
     ((string=? path "/metrics")
      (values '((content-type . (text/plain)))
              (metrics->prometheus)))
     ((string=? path "/")
      (values '((content-type . (text/plain)))
              "Hello, world!"))
     (else
      (values (build-response #:code 404
                              #:headers '((content-type . (text/plain))))
              "Not Found")))))

;; Run if executed directly
(when (and (not (null? (command-line)))
           (string-suffix? "hello.scm" (car (command-line))))
  (setup-default-metrics)
  (let ((port (if (> (length (command-line)) 1)
                  (string->number (cadr (command-line)))
                  4141)))
    (format #t "Serving metrics on http://localhost:~a/metrics~%" port)
    (run-server handler 'http `(#:port ,port))))
