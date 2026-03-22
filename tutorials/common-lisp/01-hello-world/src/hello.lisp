(defpackage :hello
  (:use :cl)
  (:export #:greet))

(in-package :hello)

(defun greet (&optional (name ""))
  (if (string= name "")
      "Hello, world!"
      (format nil "Hello, ~A!" name)))
