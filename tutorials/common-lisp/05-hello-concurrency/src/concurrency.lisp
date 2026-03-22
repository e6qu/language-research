(defpackage :hello-concurrency
  (:use :cl)
  (:export #:make-counter #:counter-value #:counter-increment
           #:fan-out-greet #:pipeline #:main))

(in-package :hello-concurrency)

;;; --- Thread-safe counter using mutex ---

(defstruct counter
  (value 0 :type integer)
  (lock (sb-thread:make-mutex :name "counter-lock")))

(defun counter-increment (counter &optional (delta 1))
  (sb-thread:with-mutex ((counter-lock counter))
    (incf (counter-value counter) delta))
  counter)

(defun counter-get (counter)
  (sb-thread:with-mutex ((counter-lock counter))
    (counter-value counter)))

;;; --- Fan-out: parallel greetings ---

(defun greet (name)
  (format nil "Hello, ~A!" name))

(defun fan-out-greet (names)
  "Greet all names in parallel, collect results."
  (let* ((results (make-array (length names) :initial-element nil))
         (threads (loop for name in names
                        for i from 0
                        collect (sb-thread:make-thread
                                 (let ((idx i) (n name))
                                   (lambda ()
                                     (setf (aref results idx) (greet n))))
                                 :name (format nil "greet-~A" name)))))
    (dolist (thread threads)
      (sb-thread:join-thread thread))
    (coerce results 'list)))

;;; --- Pipeline: chain of processing stages ---

(defun pipeline (input stages)
  "Process input through a pipeline of stages, each in its own thread.
   Uses sb-concurrency mailboxes for communication."
  (if (null stages)
      input
      ;; Simple sequential pipeline with threads for each stage
      (let* ((result input)
             (lock (sb-thread:make-mutex :name "pipeline")))
        (dolist (stage-fn stages)
          (let ((fn stage-fn)
                (val result))
            (let ((thread (sb-thread:make-thread
                           (lambda ()
                             (funcall fn val))
                           :name "pipeline-stage")))
              (setf result (sb-thread:join-thread thread)))))
        result)))

;;; --- Main demo ---

(defun main ()
  ;; Counter demo
  (format t "=== Thread-safe counter ===~%")
  (let ((c (make-counter))
        (threads nil))
    (dotimes (i 10)
      (push (sb-thread:make-thread
             (lambda ()
               (dotimes (j 100)
                 (counter-increment c)))
             :name (format nil "worker-~D" i))
            threads))
    (dolist (th threads) (sb-thread:join-thread th))
    (format t "Counter after 10 threads x 100 increments: ~D~%"
            (counter-get c)))

  ;; Fan-out demo
  (format t "~%=== Fan-out greetings ===~%")
  (let ((results (fan-out-greet '("Alice" "Bob" "Carol" "Dave"))))
    (dolist (r results) (format t "  ~A~%" r)))

  ;; Pipeline demo
  (format t "~%=== Pipeline ===~%")
  (let ((result (pipeline "  hello world  "
                          (list #'string-trim-whitespace
                                #'string-upcase
                                (lambda (s) (concatenate 'string s "!"))))))
    (format t "  Result: ~S~%" result))

  (format t "~%Done.~%"))

(defun string-trim-whitespace (s)
  (string-trim '(#\Space #\Tab #\Newline) s))
