(load "src/server.lisp")

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

(defmacro test-contains (description substring value)
  `(if (search ,substring ,value)
       (progn (incf *tests-passed*)
              (format t "  PASS: ~A~%" ,description))
       (progn (incf *tests-failed*)
              (format t "  FAIL: ~A~%    expected to contain: ~S~%    actual: ~S~%"
                      ,description ,substring ,value))))

(format t "~%Running tests...~%")

;; Test greet function
(test-equal "default greeting" "Hello, world!" (hello-web:greet))
(test-equal "named greeting" "Hello, Alice!" (hello-web:greet "Alice"))

;; Test request parsing
(test-equal "parse name from query"
            "Bob"
            (hello-web::parse-name-from-request "GET /greet?name=Bob HTTP/1.1"))
(test-equal "parse empty query"
            ""
            (hello-web::parse-name-from-request "GET /greet HTTP/1.1"))

;; Test response generation
(test-contains "greet response has greeting"
               "Hello, world!"
               (hello-web::handle-request "GET /greet HTTP/1.1"))
(test-contains "greet with name"
               "Hello, Bob!"
               (hello-web::handle-request "GET /greet?name=Bob HTTP/1.1"))
(test-contains "health endpoint"
               "\"status\":\"ok\""
               (hello-web::handle-request "GET /health HTTP/1.1"))
(test-contains "404 for unknown"
               "Not Found"
               (hello-web::handle-request "GET /unknown HTTP/1.1"))

(format t "~%~D passed, ~D failed~%" *tests-passed* *tests-failed*)
(when (> *tests-failed* 0) (sb-ext:exit :code 1))
(sb-ext:exit :code 0)
