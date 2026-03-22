(use-modules (srfi srfi-64))

(load "../src/hello.scm")

(test-begin "tui")

(let ((st (make-state)))
  (test-equal "initial cursor" 0 (state-cursor st))
  (test-equal "items count" 4 (length (state-items st))))

(let* ((st (make-state))
       (st2 (state-move-down st)))
  (test-equal "move down" 1 (state-cursor st2)))

(let* ((st (make-state))
       (st2 (state-move-up st)))
  (test-equal "move up at top stays at 0" 0 (state-cursor st2)))

(let* ((st (make-state))
       (st2 (state-move-down (state-move-down (state-move-down st)))))
  (test-equal "move down to last" 3 (state-cursor st2)))

(let* ((st (make-state))
       (st2 (state-move-down (state-move-down (state-move-down (state-move-down st))))))
  (test-equal "move down past end clamps" 3 (state-cursor st2)))

(test-assert "render contains items"
  (let ((output (render (make-state))))
    (and (string-contains output "Hello")
         (string-contains output "World"))))

(test-end "tui")
