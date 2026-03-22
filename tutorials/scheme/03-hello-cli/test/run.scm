(use-modules (srfi srfi-64))

(load "../src/hello.scm")

(test-begin "cli")

(test-equal "parse name"
  "Alice"
  (assoc-ref (parse-args '("--name" "Alice")) 'name))

(test-equal "parse greeting"
  "Hi"
  (assoc-ref (parse-args '("--greeting" "Hi")) 'greeting))

(test-equal "parse help"
  #t
  (assoc-ref (parse-args '("--help")) 'help))

(test-equal "default greeting"
  "Hello, world!"
  (format-greeting '()))

(test-equal "custom name"
  "Hello, Alice!"
  (format-greeting (parse-args '("--name" "Alice"))))

(test-equal "custom greeting and name"
  "Hi, Bob!"
  (format-greeting (parse-args '("--greeting" "Hi" "--name" "Bob"))))

(test-end "cli")
