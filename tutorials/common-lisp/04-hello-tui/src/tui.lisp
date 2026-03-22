(defpackage :hello-tui
  (:use :cl)
  (:export #:main #:render #:make-app-state #:app-state-counter
           #:app-state-message #:handle-key))

(in-package :hello-tui)

;;; --- State ---

(defstruct app-state
  (counter 0 :type integer)
  (message "Press +/- to change counter, q to quit" :type string)
  (running t :type boolean))

;;; --- ANSI escape helpers ---

(defun clear-screen ()
  (format t "~C[2J~C[H" #\Esc #\Esc))

(defun move-cursor (row col)
  (format t "~C[~D;~DH" #\Esc row col))

(defun set-color (code)
  (format t "~C[~Dm" #\Esc code))

(defun reset-color ()
  (format t "~C[0m" #\Esc))

;;; --- Rendering ---

(defun render (state &optional (stream *standard-output*))
  "Render the TUI to stream. Returns the formatted string for testing."
  (let ((lines (list
                "================================"
                "   Common Lisp TUI Demo"
                "================================"
                ""
                (format nil "   Counter: ~D" (app-state-counter state))
                ""
                (format nil "   ~A" (app-state-message state))
                ""
                "   [+] increment  [-] decrement"
                "   [r] reset      [q] quit"
                "================================")))
    (when (eq stream *standard-output*)
      (clear-screen)
      (loop for line in lines
            for row from 2
            do (move-cursor row 5)
               (set-color (if (= row 4) 36 37))  ; cyan for title
               (write-string line stream)
               (reset-color))
      (force-output stream))
    lines))

;;; --- Input handling ---

(defun handle-key (state key)
  "Process a key and return updated state. Pure function."
  (let ((new-state (copy-app-state state)))
    (cond
      ((char= key #\+)
       (incf (app-state-counter new-state))
       (setf (app-state-message new-state) "Incremented"))
      ((char= key #\-)
       (decf (app-state-counter new-state))
       (setf (app-state-message new-state) "Decremented"))
      ((char= key #\r)
       (setf (app-state-counter new-state) 0)
       (setf (app-state-message new-state) "Reset"))
      ((char= key #\q)
       (setf (app-state-running new-state) nil)
       (setf (app-state-message new-state) "Bye!")))
    new-state))

;;; --- Raw terminal mode (SBCL-specific) ---

(defun set-raw-mode (enable)
  "Set terminal to raw mode for single-char input."
  (if enable
      (sb-ext:run-program "/bin/stty" '("raw" "-echo") :input t :output nil :wait t)
      (sb-ext:run-program "/bin/stty" '("-raw" "echo") :input t :output nil :wait t)))

;;; --- Main loop ---

(defun main ()
  (let ((state (make-app-state)))
    (set-raw-mode t)
    (unwind-protect
         (loop while (app-state-running state)
               do (render state)
                  (let ((ch (read-char *standard-input* nil nil)))
                    (when ch
                      (setf state (handle-key state ch)))))
      (set-raw-mode nil)
      (clear-screen)
      (format t "Goodbye!~%"))))
