(load "src/cli.lisp")

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

;; greet tests
(test-equal "default greeting" "Hello, world!" (hello-cli:greet ""))
(test-equal "named greeting" "Hello, Bob!" (hello-cli:greet "Bob"))
(test-equal "shout greeting" "HELLO, BOB!" (hello-cli:greet "Bob" :shout t))
(test-equal "shout default" "HELLO, WORLD!" (hello-cli:greet "" :shout t))

;; parse-args tests
(let ((opts (hello-cli:parse-args '("Alice"))))
  (test-equal "positional name" "Alice" (hello-cli::cli-opts-name opts))
  (test-equal "no shout by default" nil (hello-cli::cli-opts-shout opts)))

(let ((opts (hello-cli:parse-args '("--name" "Bob" "--shout"))))
  (test-equal "flag name" "Bob" (hello-cli::cli-opts-name opts))
  (test-equal "shout flag" t (hello-cli::cli-opts-shout opts)))

(let ((opts (hello-cli:parse-args '("-h"))))
  (test-equal "help flag" t (hello-cli::cli-opts-help opts)))

(format t "~%~D passed, ~D failed~%" *tests-passed* *tests-failed*)
(when (> *tests-failed* 0) (sb-ext:exit :code 1))
(sb-ext:exit :code 0)
