.PHONY: build clean test typecheck e2e fatbin

build:
	@echo "Common Lisp is interpreted/compiled at load time"
	sbcl --noinform --non-interactive --load src/tui.lisp --eval '(quit)'

clean:
	rm -f *.fasl src/*.fasl test/*.fasl hello-tui

test:
	sbcl --noinform --non-interactive --load test/run.lisp

typecheck:
	sbcl --noinform --non-interactive --load src/tui.lisp --eval '(quit)' && echo "Syntax OK"

e2e: build
	sbcl --noinform --non-interactive --load src/tui.lisp \
	  --eval '(let* ((s (hello-tui:make-app-state)) (s2 (hello-tui:handle-key s #\+)) (s3 (hello-tui:handle-key s2 #\+))) (assert (= 2 (hello-tui:app-state-counter s3))) (format t "E2E passed~%"))' \
	  --eval '(quit)'

fatbin:
	sbcl --noinform --non-interactive --load src/tui.lisp \
	  --eval '(sb-ext:save-lisp-and-die "hello-tui" :toplevel (function hello-tui:main) :executable t)'
	@ls -la hello-tui 2>/dev/null
