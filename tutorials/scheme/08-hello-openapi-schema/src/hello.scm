;; Minimal JSON serializer for alists/nested structures
(define (json-escape s)
  (let loop ((chars (string->list s)) (result '()))
    (if (null? chars)
        (list->string (reverse result))
        (let ((c (car chars)))
          (cond
           ((char=? c #\") (loop (cdr chars) (append '(#\" #\\) result)))
           ((char=? c #\\) (loop (cdr chars) (append '(#\\ #\\) result)))
           ((char=? c #\newline) (loop (cdr chars) (append '(#\n #\\) result)))
           (else (loop (cdr chars) (cons c result))))))))

(define (to-json val)
  "Convert a Scheme value to a JSON string."
  (cond
   ((string? val) (string-append "\"" (json-escape val) "\""))
   ((number? val) (number->string val))
   ((boolean? val) (if val "true" "false"))
   ((null? val) "null")
   ((and (list? val) (pair? val) (pair? (car val)) (string? (caar val)))
    ;; alist -> JSON object
    (string-append
     "{"
     (string-join
      (map (lambda (p)
             (string-append "\"" (json-escape (car p)) "\":" (to-json (cdr p))))
           val)
      ",")
     "}"))
   ((list? val)
    ;; list -> JSON array
    (string-append
     "["
     (string-join (map to-json val) ",")
     "]"))
   (else (error "Cannot serialize to JSON" val))))

;; OpenAPI spec as nested alists
(define (openapi-spec)
  `(("openapi" . "3.0.3")
    ("info" . (("title" . "Hello API")
               ("version" . "1.0.0")
               ("description" . "A minimal greeting API")))
    ("paths" . (("/greet" .
                 (("get" .
                   (("summary" . "Get a greeting")
                    ("parameters" . ((("name" . "name")
                                      ("in" . "query")
                                      ("required" . #f)
                                      ("schema" . (("type" . "string")
                                                   ("default" . "world"))))))
                    ("responses" .
                     (("200" .
                       (("description" . "A greeting message")
                        ("content" .
                         (("application/json" .
                           (("schema" .
                             (("type" . "object")
                              ("properties" .
                               (("message" .
                                 (("type" . "string")
                                  ("example" . "Hello, world!")))))))))))))))))))
                ("/health" .
                 (("get" .
                   (("summary" . "Health check")
                    ("responses" .
                     (("200" .
                       (("description" . "Service is healthy")
                        ("content" .
                         (("text/plain" .
                           (("schema" .
                             (("type" . "string")
                              ("example" . "OK")))))))))))))))))
    ("components" . (("schemas" .
                      (("Greeting" .
                        (("type" . "object")
                         ("properties" .
                          (("message" .
                            (("type" . "string")))))))))))))

(define (spec->json)
  (to-json (openapi-spec)))

;; Run if executed directly
(when (and (not (null? (command-line)))
           (string-suffix? "hello.scm" (car (command-line))))
  (display (spec->json))
  (newline))
