(define (greet . args)
  (let ((name (if (and (pair? args) (not (string=? (car args) "")))
                  (car args)
                  #f)))
    (if name
        (string-append "Hello, " name "!")
        "Hello, world!")))
