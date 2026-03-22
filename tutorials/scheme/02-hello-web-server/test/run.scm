(use-modules (srfi srfi-11)
             (srfi srfi-64)
             (web request)
             (web uri))

(load "../src/hello.scm")

(define (make-test-request path)
  (build-request (build-uri 'http #:host "localhost" #:port 8080 #:path path)))

(test-begin "web-server")

(let-values (((headers body) (handler (make-test-request "/") #f)))
  (test-equal "root returns greeting" "Hello, world!" body))

(let-values (((headers body) (handler (make-test-request "/health") #f)))
  (test-equal "health returns OK" "OK" body))

(test-end "web-server")
