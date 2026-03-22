(use-modules (srfi srfi-11)
             (srfi srfi-64)
             (web request)
             (web response)
             (web uri))

(load "../src/hello.scm")

(test-begin "liveness-readiness-health")

;; State management tests
(mark-alive!)
(mark-unready!)

(test-assert "alive by default" (alive?))
(test-assert "not ready initially" (not (ready?)))

(mark-ready!)
(test-assert "ready after mark" (ready?))

(mark-dead!)
(test-assert "dead after mark" (not (alive?)))

(mark-alive!)
(test-assert "alive after revive" (alive?))

;; Handler tests
(define (make-test-request path)
  (build-request (build-uri 'http #:host "localhost" #:port 4143 #:path path)))

;; Liveness check when alive
(mark-alive!)
(let-values (((headers body) (handler (make-test-request "/healthz") #f)))
  (test-assert "healthz alive contains ok" (string-contains body "\"status\":\"ok\"")))

;; Liveness check when dead
(mark-dead!)
(let-values (((headers body) (handler (make-test-request "/healthz") #f)))
  (test-assert "healthz dead contains error" (string-contains body "\"status\":\"error\"")))

;; Readiness check
(mark-alive!)
(mark-ready!)
(let-values (((headers body) (handler (make-test-request "/readyz") #f)))
  (test-assert "readyz ready contains ok" (string-contains body "\"status\":\"ok\"")))

(mark-unready!)
(let-values (((headers body) (handler (make-test-request "/readyz") #f)))
  (test-assert "readyz unready contains error" (string-contains body "\"status\":\"error\"")))

;; Combined health
(mark-alive!)
(mark-ready!)
(let-values (((headers body) (handler (make-test-request "/health") #f)))
  (test-assert "health ok when alive+ready" (string-contains body "\"status\":\"ok\"")))

(mark-unready!)
(let-values (((headers body) (handler (make-test-request "/health") #f)))
  (test-assert "health error when not ready" (string-contains body "\"status\":\"error\"")))

(test-end "liveness-readiness-health")
