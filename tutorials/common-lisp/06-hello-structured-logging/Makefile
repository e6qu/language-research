.PHONY: build clean test typecheck e2e fatbin

build:
	@echo "Common Lisp is interpreted/compiled at load time"
	sbcl --noinform --non-interactive --load src/logging.lisp --eval '(quit)'

clean:
	rm -f *.fasl src/*.fasl test/*.fasl

test:
	sbcl --noinform --non-interactive --load test/run.lisp

typecheck:
	sbcl --noinform --non-interactive --load src/logging.lisp --eval '(quit)' && echo "Syntax OK"

e2e: build
	sbcl --noinform --non-interactive --load src/logging.lisp \
	  --eval '(let ((l (hello-logging:make-logger :name "e2e"))) (hello-logging:log-info l "E2E test" :status "ok"))' \
	  --eval '(quit)' | grep -q '"level":"info"'
	@echo "E2E passed"

fatbin:
	@echo "No standalone binary needed for a logging library"
