(use-modules (srfi srfi-19))

(define (json-escape s)
  "Escape a string for JSON output."
  (let loop ((chars (string->list s)) (result '()))
    (if (null? chars)
        (list->string (reverse result))
        (let ((c (car chars)))
          (cond
           ((char=? c #\") (loop (cdr chars) (append (reverse (string->list "\\\"")) result)))
           ((char=? c #\\) (loop (cdr chars) (append (reverse (string->list "\\\\")) result)))
           ((char=? c #\newline) (loop (cdr chars) (append (reverse (string->list "\\n")) result)))
           (else (loop (cdr chars) (cons c result))))))))

(define (json-pair key value)
  "Format a key-value pair as JSON."
  (string-append "\"" (json-escape key) "\":\"" (json-escape value) "\""))

(define (json-object pairs)
  "Format an alist as a JSON object."
  (string-append "{"
                 (string-join (map (lambda (p) (json-pair (car p) (cdr p))) pairs) ",")
                 "}"))

(define (current-timestamp)
  "Return current time as ISO-8601 string."
  (date->string (current-date) "~4"))

(define *log-output* (current-output-port))

(define (log-structured level message . extra-pairs)
  "Emit a structured JSON log line."
  (let ((entry (append
                (list (cons "timestamp" (current-timestamp))
                      (cons "level" level)
                      (cons "message" message))
                extra-pairs)))
    (display (json-object entry) *log-output*)
    (newline *log-output*)))

(define (log-info msg . pairs)  (apply log-structured "info" msg pairs))
(define (log-warn msg . pairs)  (apply log-structured "warn" msg pairs))
(define (log-error msg . pairs) (apply log-structured "error" msg pairs))

;; Run if executed directly
(when (and (not (null? (command-line)))
           (string-suffix? "hello.scm" (car (command-line))))
  (log-info "Application started" (cons "version" "1.0.0"))
  (log-warn "Disk space low" (cons "percent" "92"))
  (log-error "Connection failed" (cons "host" "db.example.com") (cons "port" "5432")))
