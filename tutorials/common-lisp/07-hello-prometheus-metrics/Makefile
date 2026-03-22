.PHONY: build clean test typecheck e2e fatbin

build:
	@echo "Common Lisp is interpreted/compiled at load time"
	sbcl --noinform --non-interactive --load src/metrics.lisp --eval '(quit)'

clean:
	rm -f *.fasl src/*.fasl test/*.fasl

test:
	sbcl --noinform --non-interactive --load test/run.lisp

typecheck:
	sbcl --noinform --non-interactive --load src/metrics.lisp --eval '(quit)' && echo "Syntax OK"

e2e: build
	sbcl --noinform --non-interactive --load src/metrics.lisp \
	  --eval '(let* ((reg (hello-metrics:make-registry)) (c (hello-metrics:registry-register reg (hello-metrics:make-counter :name "test_total" :help "Test")))) (hello-metrics:counter-inc c 42) (let ((out (hello-metrics:render-metrics reg))) (assert (search "test_total 42" out)) (format t "E2E passed~%")))' \
	  --eval '(quit)'

fatbin:
	@echo "No standalone binary needed for a metrics library"
