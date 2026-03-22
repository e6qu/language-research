.PHONY: build clean test typecheck e2e fatbin lint autoformat format-check

build:
	@echo "Common Lisp is interpreted/compiled at load time"
	sbcl --noinform --non-interactive --load src/hello.lisp --eval '(quit)'

clean:
	rm -f *.fasl src/*.fasl test/*.fasl hello

test:
	sbcl --noinform --non-interactive --load test/run.lisp

typecheck:
	sbcl --noinform --non-interactive --load src/hello.lisp --eval '(quit)' && echo "Syntax OK"

e2e: build
	sbcl --noinform --non-interactive --load src/hello.lisp --eval '(format t "~A~%" (hello:greet "World"))' --eval '(quit)' | grep -q "Hello, World!"
	@echo "E2E: PASS"

fatbin:
	sbcl --noinform --non-interactive --load src/hello.lisp --eval '(sb-ext:save-lisp-and-die "hello" :toplevel (lambda () (format t "~A~%" (hello:greet)) (sb-ext:exit)) :executable t)'
	@ls -la hello 2>/dev/null

lint:
	sbcl --noinform --non-interactive --load src/*.lisp --eval '(quit)'

autoformat:
	@echo "No standard Common Lisp formatter"

format-check:
	@echo "No standard Common Lisp formatter"
