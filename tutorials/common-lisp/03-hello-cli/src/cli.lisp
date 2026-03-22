(defpackage :hello-cli
  (:use :cl)
  (:export #:main #:parse-args #:greet))

(in-package :hello-cli)

(defstruct cli-opts
  (name "" :type string)
  (shout nil :type boolean)
  (help nil :type boolean))

(defun parse-args (args)
  "Parse command-line arguments into a cli-opts struct."
  (let ((opts (make-cli-opts)))
    (loop for rest on args
          for arg = (first rest)
          do (cond
               ((or (string= arg "-h") (string= arg "--help"))
                (setf (cli-opts-help opts) t))
               ((or (string= arg "-s") (string= arg "--shout"))
                (setf (cli-opts-shout opts) t))
               ((or (string= arg "-n") (string= arg "--name"))
                (when (rest rest)
                  (setf (cli-opts-name opts) (second rest))
                  (setf (cdr rest) (cddr rest))))  ; skip next
               (t
                (when (string= (cli-opts-name opts) "")
                  (setf (cli-opts-name opts) arg)))))
    opts))

(defun greet (name &key shout)
  (let ((msg (if (string= name "")
                 "Hello, world!"
                 (format nil "Hello, ~A!" name))))
    (if shout (string-upcase msg) msg)))

(defun usage ()
  (format t "Usage: hello-cli [OPTIONS] [NAME]~%~%")
  (format t "Options:~%")
  (format t "  -n, --name NAME   Name to greet~%")
  (format t "  -s, --shout       Uppercase output~%")
  (format t "  -h, --help        Show this help~%"))

(defun main ()
  (let* ((args (rest sb-ext:*posix-argv*))
         (opts (parse-args args)))
    (cond
      ((cli-opts-help opts)
       (usage)
       (sb-ext:exit :code 0))
      (t
       (format t "~A~%" (greet (cli-opts-name opts)
                                :shout (cli-opts-shout opts)))
       (sb-ext:exit :code 0)))))
