;; ANSI escape codes
(define ESC "\x1b[")

(define (ansi-clear)     (string-append ESC "2J" ESC "H"))
(define (ansi-bold s)    (string-append ESC "1m" s ESC "0m"))
(define (ansi-color n s) (string-append ESC (number->string n) "m" s ESC "0m"))
(define (ansi-move r c)  (string-append ESC (number->string r) ";" (number->string c) "H"))

;; State as association list
(define (make-state)
  '((cursor . 0)
    (items . ("Hello" "World" "Scheme" "TUI"))))

(define (state-cursor st)  (assoc-ref st 'cursor))
(define (state-items st)   (assoc-ref st 'items))

(define (state-move-down st)
  (let* ((cursor (state-cursor st))
         (items (state-items st))
         (new-cursor (min (1- (length items)) (1+ cursor))))
    (cons (cons 'cursor new-cursor)
          (filter (lambda (p) (not (eq? (car p) 'cursor))) st))))

(define (state-move-up st)
  (let* ((cursor (state-cursor st))
         (new-cursor (max 0 (1- cursor))))
    (cons (cons 'cursor new-cursor)
          (filter (lambda (p) (not (eq? (car p) 'cursor))) st))))

(define (render-item item index cursor)
  (if (= index cursor)
      (string-append "  " (ansi-bold (ansi-color 32 (string-append "> " item))))
      (string-append "    " item)))

(define (render st)
  (let ((cursor (state-cursor st))
        (items (state-items st)))
    (string-append
     (ansi-clear)
     (ansi-bold "  Hello TUI") "\n"
     (ansi-color 90 "  Use j/k to move, q to quit") "\n\n"
     (let loop ((i 0) (rest items) (lines '()))
       (if (null? rest)
           (string-join (reverse lines) "\n")
           (loop (1+ i) (cdr rest)
                 (cons (render-item (car rest) i cursor) lines))))
     "\n")))

;; Interactive loop
(define (run-tui)
  (let loop ((st (make-state)))
    (display (render st))
    (let ((ch (read-char)))
      (cond
       ((or (eof-object? ch) (char=? ch #\q))
        (display (string-append ESC "0m"))
        (newline))
       ((or (char=? ch #\j) (char=? ch #\J))
        (loop (state-move-down st)))
       ((or (char=? ch #\k) (char=? ch #\K))
        (loop (state-move-up st)))
       (else (loop st))))))

;; Run if executed directly
(when (and (not (null? (command-line)))
           (string-suffix? "hello.scm" (car (command-line))))
  (run-tui))
