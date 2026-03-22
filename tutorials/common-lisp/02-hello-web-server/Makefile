.PHONY: build clean test typecheck e2e fatbin

build:
	@echo "Common Lisp is interpreted/compiled at load time"
	sbcl --noinform --non-interactive --load src/server.lisp --eval '(quit)'

clean:
	rm -f *.fasl src/*.fasl test/*.fasl hello-web

test:
	sbcl --noinform --non-interactive --load test/run.lisp

typecheck:
	sbcl --noinform --non-interactive --load src/server.lisp --eval '(quit)' && echo "Syntax OK"

e2e: build
	sbcl --noinform --non-interactive --load src/server.lisp \
	  --eval '(sb-thread:make-thread (lambda () (hello-web:start-server 18080)))' \
	  --eval '(sleep 1)' \
	  --eval '(let* ((s (make-instance (quote sb-bsd-sockets:inet-socket) :type :stream :protocol :tcp))) (sb-bsd-sockets:socket-connect s (sb-bsd-sockets:make-inet-address "127.0.0.1") 18080) (let ((st (sb-bsd-sockets:socket-make-stream s :input t :output t :element-type (quote character) :buffering :line))) (write-string "GET /greet?name=E2E HTTP/1.1\r\nHost: localhost\r\n\r\n" st) (force-output st) (let ((resp (read-line st nil nil))) (assert (search "200" resp)) (format t "E2E passed~%"))) (sb-ext:exit :code 0))' \
	  || (echo "E2E failed" && exit 1)

fatbin:
	sbcl --noinform --non-interactive --load src/server.lisp \
	  --eval '(sb-ext:save-lisp-and-die "hello-web" :toplevel (function hello-web::main) :executable t)'
	@ls -la hello-web 2>/dev/null
