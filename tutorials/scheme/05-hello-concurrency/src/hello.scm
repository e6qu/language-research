(use-modules (ice-9 futures)
             (ice-9 threads)
             (srfi srfi-1))

(define (slow-square n)
  "Simulate a slow computation."
  (usleep 100000)  ; 100ms
  (* n n))

(define (parallel-map proc items)
  "Map proc over items using futures for parallelism."
  (let ((futures (map (lambda (x) (future (proc x))) items)))
    (map touch futures)))

(define (sequential-map proc items)
  "Map proc over items sequentially."
  (map proc items))

(define (timed-run label thunk)
  "Run thunk and return (result . elapsed-microseconds)."
  (let* ((start (get-internal-real-time))
         (result (thunk))
         (end (get-internal-real-time))
         (elapsed (/ (* 1000000 (- end start)) internal-time-units-per-second)))
    (cons result elapsed)))

;; Run if executed directly
(when (and (not (null? (command-line)))
           (string-suffix? "hello.scm" (car (command-line))))
  (let* ((items '(1 2 3 4 5))
         (seq (timed-run "sequential" (lambda () (sequential-map slow-square items))))
         (par (timed-run "parallel"   (lambda () (parallel-map slow-square items)))))
    (format #t "Sequential: ~a (~a us)~%" (car seq) (cdr seq))
    (format #t "Parallel:   ~a (~a us)~%" (car par) (cdr par))
    (let ((speedup (exact->inexact (/ (cdr seq) (max 1 (cdr par))))))
      (format #t "Speedup:    ~1,1fx~%" speedup))))
