(use-modules (srfi srfi-64))

(load "../src/hello.scm")

(test-begin "hello")

(test-equal "default greeting" "Hello, world!" (greet))
(test-equal "named greeting" "Hello, Alice!" (greet "Alice"))
(test-equal "empty string" "Hello, world!" (greet ""))

(test-end "hello")
