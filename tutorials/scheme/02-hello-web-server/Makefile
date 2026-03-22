.PHONY: build clean test typecheck e2e fatbin lint autoformat format-check

build:
	@echo "Scheme is interpreted — no compilation step"

clean:
	rm -f *.out

test:
	guile test/run.scm

typecheck:
	guile -c '(load "src/hello.scm")' && echo "Syntax OK"

e2e: build
	@lsof -ti:4140 | xargs kill 2>/dev/null || true
	guile src/hello.scm 4140 &
	@sleep 4
	curl -sf http://localhost:4140/ | grep -q "Hello, world!"
	curl -sf http://localhost:4140/greet/Test | grep -q "Hello, Test!"
	@pkill -f "guile.*hello" 2>/dev/null || true
	@echo "E2E: PASS"

fatbin:
	@echo "No fat binary support for Scheme"
	@echo "Consider Chicken Scheme (csc) for compiled binaries"

lint:
	@echo "No standard Scheme linter"

autoformat:
	@echo "No standard Scheme formatter"

format-check:
	@echo "No standard Scheme formatter"
