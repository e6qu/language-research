(require :sb-bsd-sockets)

(defpackage :hello-web
  (:use :cl)
  (:export #:start-server #:greet))

(in-package :hello-web)

(defun greet (&optional (name ""))
  (if (string= name "")
      "Hello, world!"
      (format nil "Hello, ~A!" name)))

(defun parse-name-from-request (request-line)
  "Extract name from GET /greet?name=X or return empty string."
  (let ((pos (search "name=" request-line)))
    (if pos
        (let* ((start (+ pos 5))
               (end (or (position #\Space request-line :start start)
                        (position #\& request-line :start start)
                        (length request-line))))
          (subseq request-line start end))
        "")))

(defun http-response (status-code status-text content-type body)
  (format nil "HTTP/1.1 ~D ~A~C~CContent-Type: ~A~C~CContent-Length: ~D~C~C~C~C~A"
          status-code status-text #\Return #\Newline
          content-type #\Return #\Newline
          (length body) #\Return #\Newline
          #\Return #\Newline
          body))

(defun handle-request (request-line)
  (cond
    ((search "GET /greet" request-line)
     (let ((name (parse-name-from-request request-line)))
       (http-response 200 "OK" "text/plain" (greet name))))
    ((search "GET /health" request-line)
     (http-response 200 "OK" "application/json" "{\"status\":\"ok\"}"))
    (t
     (http-response 404 "Not Found" "text/plain" "Not Found"))))

(defun read-request-line (stream)
  "Read the first line of an HTTP request."
  (let ((line (read-line stream nil nil)))
    (or line "")))

(defun start-server (&optional (port 8080))
  (let ((server-socket (make-instance 'sb-bsd-sockets:inet-socket
                                      :type :stream :protocol :tcp)))
    (setf (sb-bsd-sockets:sockopt-reuse-address server-socket) t)
    (sb-bsd-sockets:socket-bind server-socket
                                (sb-bsd-sockets:make-inet-address "127.0.0.1")
                                port)
    (sb-bsd-sockets:socket-listen server-socket 5)
    (format t "Listening on http://127.0.0.1:~D~%" port)
    (force-output)
    (unwind-protect
         (loop
           (let* ((client-socket (sb-bsd-sockets:socket-accept server-socket))
                  (client-stream (sb-bsd-sockets:socket-make-stream
                                  client-socket :input t :output t
                                  :element-type 'character :buffering :line)))
             (unwind-protect
                  (let* ((request-line (read-request-line client-stream))
                         (response (handle-request request-line)))
                    ;; Drain remaining headers
                    (loop for hdr = (read-line client-stream nil nil)
                          while (and hdr (> (length hdr) 1)))
                    (write-string response client-stream)
                    (force-output client-stream))
               (close client-stream)
               (sb-bsd-sockets:socket-close client-socket))))
      (sb-bsd-sockets:socket-close server-socket))))

;;; Entry point for standalone use
(defun main ()
  (let ((port (or (ignore-errors
                    (parse-integer (second sb-ext:*posix-argv*)))
                  8080)))
    (start-server port)))
