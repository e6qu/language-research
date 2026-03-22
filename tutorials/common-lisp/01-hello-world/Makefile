.PHONY: build clean test typecheck e2e fatbin

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
	sbcl --noinform --non-interactive --load src/hello.lisp --eval '(format t "~A~%" (hello:greet "E2E"))' --eval '(quit)' | grep -q "Hello, E2E!"
	@echo "E2E passed"

fatbin:
	sbcl --noinform --non-interactive --load src/hello.lisp --eval '(sb-ext:save-lisp-and-die "hello" :toplevel (lambda () (format t "~A~%" (hello:greet)) (sb-ext:exit)) :executable t)'
	@ls -la hello 2>/dev/null
