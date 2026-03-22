(define (parse-args args)
  "Parse command-line arguments into an alist.
   Supports --name VALUE and --greeting VALUE."
  (let loop ((remaining args) (result '()))
    (cond
     ((null? remaining) result)
     ((and (string=? (car remaining) "--name")
           (pair? (cdr remaining)))
      (loop (cddr remaining) (cons (cons 'name (cadr remaining)) result)))
     ((and (string=? (car remaining) "--greeting")
           (pair? (cdr remaining)))
      (loop (cddr remaining) (cons (cons 'greeting (cadr remaining)) result)))
     ((string=? (car remaining) "--shout")
      (loop (cdr remaining) (cons (cons 'shout #t) result)))
     ((string=? (car remaining) "--help")
      (cons (cons 'help #t) result))
     (else
      (loop (cdr remaining) result)))))

(define (format-greeting opts)
  (let* ((greeting (or (assoc-ref opts 'greeting) "Hello"))
         (name (or (assoc-ref opts 'name) "world"))
         (message (string-append greeting ", " name "!")))
    (if (assoc-ref opts 'shout)
        (string-upcase message)
        message)))

(define (usage)
  (string-join
   '("Usage: guile src/hello.scm [OPTIONS]"
     "  --name NAME        Name to greet (default: world)"
     "  --greeting GREETING Greeting word (default: Hello)"
     "  --help             Show this help")
   "\n"))

;; Run if executed directly
(when (and (not (null? (command-line)))
           (string-suffix? "hello.scm" (car (command-line))))
  (let ((opts (parse-args (cdr (command-line)))))
    (if (assoc-ref opts 'help)
        (display (usage))
        (display (format-greeting opts)))
    (newline)))
