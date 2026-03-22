(load "src/concurrency.lisp")

(in-package :cl-user)

(defvar *tests-passed* 0)
(defvar *tests-failed* 0)

(defmacro test-equal (description expected actual)
  `(if (equal ,expected ,actual)
       (progn (incf *tests-passed*)
              (format t "  PASS: ~A~%" ,description))
       (progn (incf *tests-failed*)
              (format t "  FAIL: ~A~%    expected: ~S~%    actual:   ~S~%"
                      ,description ,expected ,actual))))

(format t "~%Running tests...~%")

;; Counter basics
(let ((c (hello-concurrency:make-counter)))
  (test-equal "initial counter" 0 (hello-concurrency:counter-value c))
  (hello-concurrency:counter-increment c)
  (test-equal "after increment" 1 (hello-concurrency:counter-value c))
  (hello-concurrency:counter-increment c 5)
  (test-equal "increment by 5" 6 (hello-concurrency:counter-value c)))

;; Thread safety
(let ((c (hello-concurrency:make-counter))
      (threads nil))
  (dotimes (i 10)
    (push (sb-thread:make-thread
           (lambda ()
             (dotimes (j 100)
               (hello-concurrency:counter-increment c))))
          threads))
  (dolist (th threads) (sb-thread:join-thread th))
  (test-equal "thread-safe counter" 1000 (hello-concurrency:counter-value c)))

;; Fan-out
(let ((results (hello-concurrency:fan-out-greet '("A" "B" "C"))))
  (test-equal "fan-out count" 3 (length results))
  (test-equal "fan-out first" "Hello, A!" (first results))
  (test-equal "fan-out second" "Hello, B!" (second results))
  (test-equal "fan-out third" "Hello, C!" (third results)))

;; Pipeline
(let ((result (hello-concurrency:pipeline "hello"
               (list #'string-upcase
                     (lambda (s) (concatenate 'string s "!"))))))
  (test-equal "pipeline" "HELLO!" result))

(let ((result (hello-concurrency:pipeline "test" '())))
  (test-equal "empty pipeline" "test" result))

(format t "~%~D passed, ~D failed~%" *tests-passed* *tests-failed*)
(when (> *tests-failed* 0) (sb-ext:exit :code 1))
(sb-ext:exit :code 0)
