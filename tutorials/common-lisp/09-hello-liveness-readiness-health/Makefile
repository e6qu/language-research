.PHONY: build clean test typecheck e2e fatbin lint autoformat format-check

build:
	@echo "Common Lisp is interpreted/compiled at load time"
	sbcl --noinform --non-interactive --load src/health.lisp --eval '(quit)'

clean:
	rm -f *.fasl src/*.fasl test/*.fasl hello-health

test:
	sbcl --noinform --non-interactive --load test/run.lisp

typecheck:
	sbcl --noinform --non-interactive --load src/health.lisp --eval '(quit)' && echo "Syntax OK"

e2e: build
	sbcl --noinform --non-interactive --load src/health.lisp \
	  --eval '(sb-thread:make-thread (lambda () (let ((c (hello-health:make-health-checker))) (hello-health:set-ready c t) (hello-health:add-check c "test" (lambda () (values t "ok"))) (hello-health:start-server c 4153))))' \
	  --eval '(sleep 1)' \
	  --eval '(let* ((s (make-instance (quote sb-bsd-sockets:inet-socket) :type :stream :protocol :tcp))) (sb-bsd-sockets:socket-connect s (sb-bsd-sockets:make-inet-address "127.0.0.1") 4153) (let ((st (sb-bsd-sockets:socket-make-stream s :input t :output t :element-type (quote character) :buffering :line))) (write-string "GET /livez HTTP/1.1\r\nHost: localhost\r\n\r\n" st) (force-output st) (let ((resp (read-line st nil nil))) (assert (search "200" resp)) (format t "E2E passed~%"))) (sb-ext:exit :code 0))' \
	  || (echo "E2E failed" && exit 1)

fatbin:
	sbcl --noinform --non-interactive --load src/health.lisp \
	  --eval '(sb-ext:save-lisp-and-die "hello-health" :toplevel (function hello-health:main) :executable t)'
	@ls -la hello-health 2>/dev/null

lint:
	sbcl --noinform --non-interactive --load src/*.lisp --eval '(quit)'

autoformat:
	@echo "No standard Common Lisp formatter"

format-check:
	@echo "No standard Common Lisp formatter"
