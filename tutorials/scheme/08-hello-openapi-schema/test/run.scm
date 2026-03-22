(use-modules (srfi srfi-64))

(load "../src/hello.scm")

(test-begin "openapi-schema")

;; JSON serializer tests
(test-equal "string" "\"hello\"" (to-json "hello"))
(test-equal "number" "42" (to-json 42))
(test-equal "boolean true" "true" (to-json #t))
(test-equal "boolean false" "false" (to-json #f))
(test-equal "empty list" "[]" (to-json '()))
(test-equal "array" "[1,2,3]" (to-json '(1 2 3)))
(test-equal "object" "{\"a\":\"b\"}" (to-json '(("a" . "b"))))

;; Spec structure tests
(let ((spec (openapi-spec)))
  (test-equal "openapi version"
    "3.0.3"
    (assoc-ref spec "openapi"))

  (test-equal "info title"
    "Hello API"
    (assoc-ref (assoc-ref spec "info") "title"))

  (test-assert "has /greet path"
    (assoc-ref (assoc-ref spec "paths") "/greet"))

  (test-assert "has /health path"
    (assoc-ref (assoc-ref spec "paths") "/health")))

;; Full JSON output test
(let ((json (spec->json)))
  (test-assert "json contains openapi" (string-contains json "\"openapi\":\"3.0.3\""))
  (test-assert "json contains paths" (string-contains json "\"/greet\"")))

(test-end "openapi-schema")
