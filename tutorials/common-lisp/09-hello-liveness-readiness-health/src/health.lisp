(require :sb-bsd-sockets)

(defpackage :hello-health
  (:use :cl)
  (:export #:make-health-checker #:check-liveness #:check-readiness #:check-health
           #:add-check #:set-ready #:health-status #:render-json
           #:start-server #:main))

(in-package :hello-health)

;;; --- JSON helper (minimal) ---

(defun json-escape (s)
  (with-output-to-string (out)
    (loop for ch across s
          do (case ch
               (#\" (write-string "\\\"" out))
               (#\\ (write-string "\\\\" out))
               (otherwise (write-char ch out))))))

(defun render-json (value)
  (with-output-to-string (out)
    (render-json-to out value)))

(defun render-json-to (stream value)
  (cond
    ((null value) (write-string "null" stream))
    ((eq value t) (write-string "true" stream))
    ((eq value :false) (write-string "false" stream))
    ((integerp value) (format stream "~D" value))
    ((stringp value)
     (format stream "\"~A\"" (json-escape value)))
    ((and (consp value) (consp (car value)) (stringp (caar value)))
     ;; alist -> object
     (write-char #\{ stream)
     (loop for (k . v) in value
           for first = t then nil
           do (unless first (write-char #\, stream))
              (format stream "\"~A\":" k)
              (render-json-to stream v))
     (write-char #\} stream))
    ((listp value)
     (write-char #\[ stream)
     (loop for item in value
           for first = t then nil
           do (unless first (write-char #\, stream))
              (render-json-to stream item))
     (write-char #\] stream))
    (t (format stream "\"~A\"" value))))

;;; --- Health checker ---

(defstruct health-checker
  (ready nil :type boolean)
  (checks nil :type list)   ; alist of (name . check-fn)
  (lock (sb-thread:make-mutex :name "health")))

(defun add-check (checker name check-fn)
  "Add a named health check function. check-fn returns (values ok-p message)."
  (sb-thread:with-mutex ((health-checker-lock checker))
    (push (cons name check-fn) (health-checker-checks checker)))
  checker)

(defun set-ready (checker ready-p)
  (sb-thread:with-mutex ((health-checker-lock checker))
    (setf (health-checker-ready checker) ready-p))
  checker)

(defun check-liveness ()
  "Liveness: always ok if process is running."
  `(("status" . "ok")))

(defun check-readiness (checker)
  "Readiness: ok only if explicitly set ready."
  (let ((ready (sb-thread:with-mutex ((health-checker-lock checker))
                 (health-checker-ready checker))))
    `(("status" . ,(if ready "ok" "not_ready"))
      ("ready" . ,(if ready t :false)))))

(defun check-health (checker)
  "Run all registered health checks, return aggregate status."
  (let ((checks (sb-thread:with-mutex ((health-checker-lock checker))
                  (copy-list (health-checker-checks checker))))
        (all-ok t)
        (results nil))
    (dolist (check checks)
      (let ((name (car check))
            (fn (cdr check)))
        (handler-case
            (multiple-value-bind (ok-p message) (funcall fn)
              (push `(,name . (("ok" . ,(if ok-p t :false))
                               ("message" . ,(or message ""))))
                    results)
              (unless ok-p (setf all-ok nil)))
          (error (e)
            (push `(,name . (("ok" . :false)
                             ("message" . ,(format nil "~A" e))))
                  results)
            (setf all-ok nil)))))
    `(("status" . ,(if all-ok "ok" "degraded"))
      ("checks" . ,(nreverse results)))))

(defun health-status (checker)
  "Return full health status combining all endpoints."
  `(("liveness" . ,(check-liveness))
    ("readiness" . ,(check-readiness checker))
    ("health" . ,(check-health checker))))

;;; --- HTTP server ---

(defun http-response (status-code status-text content-type body)
  (format nil "HTTP/1.1 ~D ~A~C~CContent-Type: ~A~C~CContent-Length: ~D~C~C~C~C~A"
          status-code status-text #\Return #\Newline
          content-type #\Return #\Newline
          (length body) #\Return #\Newline
          #\Return #\Newline
          body))

(defun handle-request (checker request-line)
  (cond
    ((search "GET /livez" request-line)
     (http-response 200 "OK" "application/json"
                    (render-json (check-liveness))))
    ((search "GET /readyz" request-line)
     (let* ((result (check-readiness checker))
            (ready (cdr (assoc "ready" result :test #'equal))))
       (http-response (if (eq ready t) 200 503)
                      (if (eq ready t) "OK" "Service Unavailable")
                      "application/json"
                      (render-json result))))
    ((search "GET /healthz" request-line)
     (let* ((result (check-health checker))
            (status (cdr (assoc "status" result :test #'equal))))
       (http-response (if (string= status "ok") 200 503)
                      (if (string= status "ok") "OK" "Service Unavailable")
                      "application/json"
                      (render-json result))))
    (t (http-response 404 "Not Found" "text/plain" "Not Found"))))

(defun start-server (checker &optional (port 4153))
  (let ((server-socket (make-instance 'sb-bsd-sockets:inet-socket
                                      :type :stream :protocol :tcp)))
    (setf (sb-bsd-sockets:sockopt-reuse-address server-socket) t)
    (sb-bsd-sockets:socket-bind server-socket
                                (sb-bsd-sockets:make-inet-address "127.0.0.1")
                                port)
    (sb-bsd-sockets:socket-listen server-socket 5)
    (format t "Health server on http://127.0.0.1:~D~%" port)
    (format t "  GET /livez    - liveness~%")
    (format t "  GET /readyz   - readiness~%")
    (format t "  GET /healthz  - full health~%")
    (force-output)
    (unwind-protect
         (loop
           (let* ((client (sb-bsd-sockets:socket-accept server-socket))
                  (stream (sb-bsd-sockets:socket-make-stream
                           client :input t :output t
                           :element-type 'character :buffering :line)))
             (unwind-protect
                  (let ((request-line (read-line stream nil "")))
                    (loop for hdr = (read-line stream nil nil)
                          while (and hdr (> (length hdr) 1)))
                    (write-string (handle-request checker request-line) stream)
                    (force-output stream))
               (close stream)
               (sb-bsd-sockets:socket-close client))))
      (sb-bsd-sockets:socket-close server-socket))))

(defun main ()
  (let ((checker (make-health-checker)))
    ;; Register checks
    (add-check checker "database"
               (lambda () (values t "connected")))
    (add-check checker "disk"
               (lambda () (values t "ok")))
    ;; Mark ready after setup
    (set-ready checker t)
    (start-server checker
                  (or (ignore-errors (parse-integer (second sb-ext:*posix-argv*)))
                      4153))))
