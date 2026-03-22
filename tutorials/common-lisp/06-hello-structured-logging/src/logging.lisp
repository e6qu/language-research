(defpackage :hello-logging
  (:use :cl)
  (:export #:make-logger #:log-info #:log-warn #:log-error #:log-debug
           #:format-json #:*log-level* #:*log-output*))

(in-package :hello-logging)

;;; --- Log levels ---

(defparameter *log-levels* '(:debug 0 :info 1 :warn 2 :error 3))
(defvar *log-level* :info)
(defvar *log-output* *standard-output*)

(defun level-value (level)
  (getf *log-levels* level 1))

(defun level-enabled-p (level)
  (>= (level-value level) (level-value *log-level*)))

;;; --- JSON formatting (no deps) ---

(defun json-escape (string)
  "Escape a string for JSON output."
  (with-output-to-string (out)
    (loop for ch across string
          do (case ch
               (#\" (write-string "\\\"" out))
               (#\\ (write-string "\\\\" out))
               (#\Newline (write-string "\\n" out))
               (#\Return (write-string "\\r" out))
               (#\Tab (write-string "\\t" out))
               (otherwise (write-char ch out))))))

(defun format-json (pairs)
  "Format an alist of (key . value) pairs as a JSON object string."
  (with-output-to-string (out)
    (write-char #\{ out)
    (loop for (key . value) in pairs
          for first = t then nil
          do (unless first (write-string "," out))
             (format out "\"~A\":" (json-escape (string-downcase (string key))))
             (typecase value
               (integer (format out "~D" value))
               (float (format out "~F" value))
               (null (write-string "false" out))
               ((eql t) (write-string "true" out))
               (otherwise (format out "\"~A\"" (json-escape (princ-to-string value))))))
    (write-char #\} out)))

;;; --- Timestamp ---

(defun iso-timestamp ()
  (multiple-value-bind (sec min hour day month year)
      (get-decoded-time)
    (format nil "~4,'0D-~2,'0D-~2,'0DT~2,'0D:~2,'0D:~2,'0DZ"
            year month day hour min sec)))

;;; --- Logger ---

(defstruct logger
  (name "app" :type string)
  (fields nil :type list))  ; default fields as alist

(defun make-log-entry (logger level message extra-fields)
  (let ((base-fields `(("timestamp" . ,(iso-timestamp))
                       ("level" . ,(string-downcase (string level)))
                       ("logger" . ,(logger-name logger))
                       ("message" . ,message))))
    (append base-fields (logger-fields logger) extra-fields)))

(defun emit-log (logger level message &rest extra-fields)
  "Emit a structured log entry if level is enabled."
  (when (level-enabled-p level)
    (let* ((pairs (loop for (k v) on extra-fields by #'cddr
                        collect (cons (string-downcase (string k)) v)))
           (entry (make-log-entry logger level message pairs)))
      (format *log-output* "~A~%" (format-json entry))
      (force-output *log-output*)
      entry)))

;;; --- Convenience functions ---

(defun log-debug (logger message &rest fields)
  (apply #'emit-log logger :debug message fields))

(defun log-info (logger message &rest fields)
  (apply #'emit-log logger :info message fields))

(defun log-warn (logger message &rest fields)
  (apply #'emit-log logger :warn message fields))

(defun log-error (logger message &rest fields)
  (apply #'emit-log logger :error message fields))
