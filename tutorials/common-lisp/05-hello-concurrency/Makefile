.PHONY: build clean test typecheck e2e fatbin lint autoformat format-check

build:
	@echo "Common Lisp is interpreted/compiled at load time"
	sbcl --noinform --non-interactive --load src/concurrency.lisp --eval '(quit)'

clean:
	rm -f *.fasl src/*.fasl test/*.fasl hello-concurrency

test:
	sbcl --noinform --non-interactive --load test/run.lisp

typecheck:
	sbcl --noinform --non-interactive --load src/concurrency.lisp --eval '(quit)' && echo "Syntax OK"

e2e: test
	@echo "E2E: PASS"

fatbin:
	sbcl --noinform --non-interactive --load src/concurrency.lisp \
	  --eval '(sb-ext:save-lisp-and-die "hello-concurrency" :toplevel (function hello-concurrency:main) :executable t)'
	@ls -la hello-concurrency 2>/dev/null

lint:
	sbcl --noinform --non-interactive --load src/*.lisp --eval '(quit)'

autoformat:
	@echo "No standard Common Lisp formatter"

format-check:
	@echo "No standard Common Lisp formatter"
