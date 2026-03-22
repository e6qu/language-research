(load "src/logging.lisp")

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

;; JSON formatting
(test-equal "empty json" "{}" (hello-logging:format-json nil))
(test-equal "single pair"
            "{\"name\":\"Alice\"}"
            (hello-logging:format-json '(("name" . "Alice"))))
(test-equal "integer value"
            "{\"count\":42}"
            (hello-logging:format-json '(("count" . 42))))
(test-equal "boolean true"
            "{\"ok\":true}"
            (hello-logging:format-json '(("ok" . t))))
(test-equal "multiple pairs"
            "{\"a\":1,\"b\":\"x\"}"
            (hello-logging:format-json '(("a" . 1) ("b" . "x"))))

;; JSON escaping
(test-contains "escapes quotes"
               "\\\""
               (hello-logging:format-json '(("msg" . "say \"hi\""))))

;; Logger
(let* ((logger (hello-logging:make-logger :name "test"))
       (output (make-string-output-stream)))
  (let ((hello-logging:*log-output* output))
    (hello-logging:log-info logger "hello" :user "Alice"))
  (let ((result (get-output-stream-string output)))
    (test-contains "has level" "\"level\":\"info\"" result)
    (test-contains "has message" "\"message\":\"hello\"" result)
    (test-contains "has user field" "\"user\":\"Alice\"" result)
    (test-contains "has logger name" "\"logger\":\"test\"" result)))

;; Log level filtering
(let* ((logger (hello-logging:make-logger :name "test"))
       (output (make-string-output-stream)))
  (let ((hello-logging:*log-output* output)
        (hello-logging:*log-level* :warn))
    (hello-logging:log-info logger "should be filtered")
    (hello-logging:log-warn logger "should appear"))
  (let ((result (get-output-stream-string output)))
    (test-equal "info filtered" nil (search "should be filtered" result))
    (test-contains "warn appears" "should appear" result)))

(format t "~%~D passed, ~D failed~%" *tests-passed* *tests-failed*)
(when (> *tests-failed* 0) (sb-ext:exit :code 1))
(sb-ext:exit :code 0)
