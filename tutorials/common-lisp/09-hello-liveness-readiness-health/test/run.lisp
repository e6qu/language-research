(load "src/health.lisp")

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

(defun aget (key alist)
  (cdr (assoc key alist :test #'equal)))

(format t "~%Running tests...~%")

;; Liveness always ok
(let ((result (hello-health:check-liveness)))
  (test-equal "liveness status" "ok" (aget "status" result)))

;; Readiness before set
(let ((checker (hello-health:make-health-checker)))
  (let ((result (hello-health:check-readiness checker)))
    (test-equal "not ready initially" "not_ready" (aget "status" result))
    (test-equal "ready flag false" :false (aget "ready" result)))

  ;; Set ready
  (hello-health:set-ready checker t)
  (let ((result (hello-health:check-readiness checker)))
    (test-equal "ready after set" "ok" (aget "status" result))
    (test-equal "ready flag true" t (aget "ready" result))))

;; Health checks - all pass
(let ((checker (hello-health:make-health-checker)))
  (hello-health:add-check checker "db"
    (lambda () (values t "connected")))
  (hello-health:add-check checker "cache"
    (lambda () (values t "warm")))
  (let ((result (hello-health:check-health checker)))
    (test-equal "all healthy" "ok" (aget "status" result))
    (test-equal "two checks" 2 (length (aget "checks" result)))))

;; Health checks - one fails
(let ((checker (hello-health:make-health-checker)))
  (hello-health:add-check checker "db"
    (lambda () (values t "ok")))
  (hello-health:add-check checker "cache"
    (lambda () (values nil "connection refused")))
  (let ((result (hello-health:check-health checker)))
    (test-equal "degraded status" "degraded" (aget "status" result))))

;; Health check - error in check
(let ((checker (hello-health:make-health-checker)))
  (hello-health:add-check checker "bad"
    (lambda () (error "boom")))
  (let ((result (hello-health:check-health checker)))
    (test-equal "error -> degraded" "degraded" (aget "status" result))))

;; JSON rendering
(let ((json (hello-health:render-json '(("status" . "ok") ("ready" . t)))))
  (test-contains "json has status" "\"status\":\"ok\"" json)
  (test-contains "json has ready" "\"ready\":true" json))

;; Full status
(let ((checker (hello-health:make-health-checker)))
  (hello-health:set-ready checker t)
  (hello-health:add-check checker "db" (lambda () (values t "ok")))
  (let ((status (hello-health:health-status checker)))
    (test-equal "has liveness" t (not (null (aget "liveness" status))))
    (test-equal "has readiness" t (not (null (aget "readiness" status))))
    (test-equal "has health" t (not (null (aget "health" status))))))

;; HTTP response generation
(let* ((checker (hello-health:make-health-checker))
       (resp (hello-health::handle-request checker "GET /livez HTTP/1.1")))
  (test-contains "livez 200" "200 OK" resp)
  (test-contains "livez json" "\"status\":\"ok\"" resp))

(let* ((checker (hello-health:make-health-checker))
       (resp (hello-health::handle-request checker "GET /readyz HTTP/1.1")))
  (test-contains "readyz 503 when not ready" "503" resp))

(format t "~%~D passed, ~D failed~%" *tests-passed* *tests-failed*)
(when (> *tests-failed* 0) (sb-ext:exit :code 1))
(sb-ext:exit :code 0)
