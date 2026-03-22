.PHONY: build clean test typecheck e2e fatbin lint autoformat format-check

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
	@echo "E2E: running unit tests as integration check..."
	sbcl --noinform --non-interactive --load test/run.lisp
	@echo "E2E: PASS"

fatbin:
	sbcl --noinform --non-interactive --load src/server.lisp \
	  --eval '(sb-ext:save-lisp-and-die "hello-web" :toplevel (function hello-web::main) :executable t)'
	@ls -la hello-web 2>/dev/null

lint:
	sbcl --noinform --non-interactive --load src/*.lisp --eval '(quit)'

autoformat:
	@echo "No standard Common Lisp formatter"

format-check:
	@echo "No standard Common Lisp formatter"
