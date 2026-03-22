(load "src/tui.lisp")

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

;; Initial state
(let ((state (hello-tui:make-app-state)))
  (test-equal "initial counter" 0 (hello-tui:app-state-counter state)))

;; Increment
(let* ((state (hello-tui:make-app-state))
       (next (hello-tui:handle-key state #\+)))
  (test-equal "increment counter" 1 (hello-tui:app-state-counter next))
  (test-equal "increment message" "Incremented" (hello-tui:app-state-message next)))

;; Decrement
(let* ((state (hello-tui:make-app-state))
       (next (hello-tui:handle-key state #\-)))
  (test-equal "decrement counter" -1 (hello-tui:app-state-counter next))
  (test-equal "decrement message" "Decremented" (hello-tui:app-state-message next)))

;; Reset
(let* ((state (hello-tui:make-app-state))
       (s1 (hello-tui:handle-key state #\+))
       (s2 (hello-tui:handle-key s1 #\+))
       (s3 (hello-tui:handle-key s2 #\r)))
  (test-equal "reset counter" 0 (hello-tui:app-state-counter s3))
  (test-equal "reset message" "Reset" (hello-tui:app-state-message s3)))

;; Quit
(let* ((state (hello-tui:make-app-state))
       (next (hello-tui:handle-key state #\q)))
  (test-equal "quit stops running" nil (hello-tui::app-state-running next)))

;; Render returns lines
(let* ((state (hello-tui:make-app-state))
       (lines (hello-tui:render state nil)))
  (test-equal "render returns list" t (listp lines))
  (test-equal "render has lines" t (> (length lines) 5)))

(format t "~%~D passed, ~D failed~%" *tests-passed* *tests-failed*)
(when (> *tests-failed* 0) (sb-ext:exit :code 1))
(sb-ext:exit :code 0)
