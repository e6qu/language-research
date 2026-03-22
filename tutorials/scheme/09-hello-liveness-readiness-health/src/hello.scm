(use-modules (web server)
             (web request)
             (web response)
             (web uri)
             (srfi srfi-19))

;; Mutable application state
(define *app-state*
  (list (cons 'ready #f)
        (cons 'live #t)
        (cons 'start-time (current-time))))

(define (state-ref key)
  (assoc-ref *app-state* key))

(define (state-set! key value)
  (set! *app-state*
    (cons (cons key value)
          (filter (lambda (p) (not (eq? (car p) key))) *app-state*))))

(define (mark-ready!)  (state-set! 'ready #t))
(define (mark-unready!) (state-set! 'ready #f))
(define (mark-dead!)   (state-set! 'live #f))
(define (mark-alive!)  (state-set! 'live #t))

(define (ready?) (state-ref 'ready))
(define (alive?) (state-ref 'live))

(define (uptime-seconds)
  (let ((start (state-ref 'start-time))
        (now (current-time)))
    (time-second (time-difference now start))))

(define (json-escape s)
  (let loop ((chars (string->list s)) (result '()))
    (if (null? chars)
        (list->string (reverse result))
        (let ((c (car chars)))
          (cond
           ((char=? c #\") (loop (cdr chars) (append '(#\" #\\) result)))
           ((char=? c #\\) (loop (cdr chars) (append '(#\\ #\\) result)))
           (else (loop (cdr chars) (cons c result))))))))

(define (health-response status message uptime)
  (string-append
   "{\"status\":\"" (json-escape status) "\""
   ",\"message\":\"" (json-escape message) "\""
   ",\"uptime\":" (number->string uptime) "}"))

(define (request-path request)
  (uri-path (request-uri request)))

(define (handler request body)
  (let ((path (request-path request)))
    (cond
     ((string=? path "/healthz")
      (if (alive?)
          (values '((content-type . (application/json)))
                  (health-response "ok" "alive" (uptime-seconds)))
          (values (build-response #:code 503
                                  #:headers '((content-type . (application/json))))
                  (health-response "error" "not alive" (uptime-seconds)))))
     ((string=? path "/readyz")
      (if (ready?)
          (values '((content-type . (application/json)))
                  (health-response "ok" "ready" (uptime-seconds)))
          (values (build-response #:code 503
                                  #:headers '((content-type . (application/json))))
                  (health-response "error" "not ready" (uptime-seconds)))))
     ((string=? path "/health")
      (let* ((is-alive (alive?))
             (is-ready (ready?))
             (ok (and is-alive is-ready)))
        (if ok
            (values '((content-type . (application/json)))
                    (health-response "ok" "healthy" (uptime-seconds)))
            (values (build-response #:code 503
                                    #:headers '((content-type . (application/json))))
                    (health-response "error" "unhealthy" (uptime-seconds))))))
     (else
      (values (build-response #:code 404
                              #:headers '((content-type . (text/plain))))
              "Not Found")))))

;; Run if executed directly
(when (and (not (null? (command-line)))
           (string-suffix? "hello.scm" (car (command-line))))
  (mark-ready!)
  (let ((port (if (> (length (command-line)) 1)
                  (string->number (cadr (command-line)))
                  8080)))
    (format #t "Health server on http://localhost:~a~%" port)
    (format #t "  /healthz  - liveness~%")
    (format #t "  /readyz   - readiness~%")
    (format #t "  /health   - combined~%")
    (run-server handler 'http `(#:port ,port))))
