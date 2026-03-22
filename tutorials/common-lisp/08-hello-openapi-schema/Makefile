.PHONY: build clean test typecheck e2e fatbin lint autoformat format-check

build:
	@echo "Common Lisp is interpreted/compiled at load time"
	sbcl --noinform --non-interactive --load src/openapi.lisp --eval '(quit)'

clean:
	rm -f *.fasl src/*.fasl test/*.fasl

test:
	sbcl --noinform --non-interactive --load test/run.lisp

typecheck:
	sbcl --noinform --non-interactive --load src/openapi.lisp --eval '(quit)' && echo "Syntax OK"

e2e: build
	sbcl --noinform --non-interactive --load src/openapi.lisp \
	  --eval '(let* ((spec (hello-openapi:make-spec :title "E2E")) (json (hello-openapi:render-json spec))) (assert (search "openapi" json)) (format t "E2E passed~%"))' \
	  --eval '(quit)'

fatbin:
	@echo "No standalone binary needed for a schema library"

lint:
	sbcl --noinform --non-interactive --load src/*.lisp --eval '(quit)'

autoformat:
	@echo "No standard Common Lisp formatter"

format-check:
	@echo "No standard Common Lisp formatter"
