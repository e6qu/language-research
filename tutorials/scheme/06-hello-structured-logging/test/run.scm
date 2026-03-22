(use-modules (srfi srfi-64))

(load "../src/hello.scm")

(test-begin "structured-logging")

(test-equal "json-escape plain"
  "hello"
  (json-escape "hello"))

(test-equal "json-escape quotes"
  "say \\\"hi\\\""
  (json-escape "say \"hi\""))

(test-equal "json-escape backslash"
  "a\\\\b"
  (json-escape "a\\b"))

(test-equal "json-pair"
  "\"key\":\"value\""
  (json-pair "key" "value"))

(test-equal "json-object"
  "{\"a\":\"1\",\"b\":\"2\"}"
  (json-object '(("a" . "1") ("b" . "2"))))

(test-equal "json-object empty"
  "{}"
  (json-object '()))

;; Test log output capture
(let* ((port (open-output-string)))
  (set! *log-output* port)
  (log-info "test message" (cons "key" "val"))
  (set! *log-output* (current-output-port))
  (let ((output (get-output-string port)))
    (test-assert "log contains level" (string-contains output "\"level\":\"info\""))
    (test-assert "log contains message" (string-contains output "\"message\":\"test message\""))
    (test-assert "log contains extra" (string-contains output "\"key\":\"val\""))))

(test-end "structured-logging")
