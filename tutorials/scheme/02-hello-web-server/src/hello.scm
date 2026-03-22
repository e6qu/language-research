(use-modules (web server)
             (web request)
             (web response)
             (web uri))

(define (request-path request)
  (uri-path (request-uri request)))

(define (handler request body)
  (let ((path (request-path request)))
    (cond
     ((string=? path "/")
      (values '((content-type . (text/plain)))
              "Hello, world!"))
     ((string-prefix? "/greet/" path)
      (let ((name (substring path (string-length "/greet/"))))
        (values '((content-type . (text/plain)))
                (string-append "Hello, " name "!"))))
     ((string=? path "/health")
      (values '((content-type . (text/plain)))
              "OK"))
     (else
      (values (build-response #:code 404
                              #:headers '((content-type . (text/plain))))
              "Not Found")))))

(define (start-server port)
  (run-server handler 'http `(#:port ,port)))

;; Run if executed directly
(when (and (not (null? (command-line)))
           (string-suffix? "hello.scm" (car (command-line))))
  (let ((port (if (> (length (command-line)) 1)
                  (string->number (cadr (command-line)))
                  4140)))
    (format #t "Listening on port ~a~%" port)
    (start-server port)))
