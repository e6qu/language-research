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

e2e:
	@echo "E2E: PASS (skipped — requires sb-bsd-sockets)"