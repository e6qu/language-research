.PHONY: build clean test typecheck e2e fatbin lint autoformat format-check

build:
	@echo "Common Lisp is interpreted/compiled at load time"
	sbcl --noinform --non-interactive --load src/cli.lisp --eval '(quit)'

clean:
	rm -f *.fasl src/*.fasl test/*.fasl hello-cli

test:
	sbcl --noinform --non-interactive --load test/run.lisp

typecheck:
	sbcl --noinform --non-interactive --load src/cli.lisp --eval '(quit)' && echo "Syntax OK"

e2e: build
	sbcl --noinform --non-interactive --load src/cli.lisp \
	  --eval '(format t "~A~%" (hello-cli:greet "E2E" :shout t))' \
	  --eval '(quit)' | grep -q "HELLO, E2E!"
	@echo "E2E passed"

fatbin:
	sbcl --noinform --non-interactive --load src/cli.lisp \
	  --eval '(sb-ext:save-lisp-and-die "hello-cli" :toplevel (function hello-cli:main) :executable t)'
	@ls -la hello-cli 2>/dev/null

lint:
	sbcl --noinform --non-interactive --load src/*.lisp --eval '(quit)'

autoformat:
	@echo "No standard Common Lisp formatter"

format-check:
	@echo "No standard Common Lisp formatter"
