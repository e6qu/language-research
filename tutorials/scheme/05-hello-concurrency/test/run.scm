(use-modules (srfi srfi-64))

(load "../src/hello.scm")

(test-begin "concurrency")

(test-equal "sequential-map squares"
  '(1 4 9 16 25)
  (sequential-map (lambda (n) (* n n)) '(1 2 3 4 5)))

(test-equal "parallel-map squares"
  '(1 4 9 16 25)
  (parallel-map (lambda (n) (* n n)) '(1 2 3 4 5)))

(test-equal "parallel-map empty"
  '()
  (parallel-map (lambda (n) (* n n)) '()))

(test-equal "parallel-map single"
  '(49)
  (parallel-map (lambda (n) (* n n)) '(7)))

(let* ((result (timed-run "test" (lambda () 42))))
  (test-equal "timed-run returns result" 42 (car result))
  (test-assert "timed-run returns elapsed" (>= (cdr result) 0)))

(test-end "concurrency")
