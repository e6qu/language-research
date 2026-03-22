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
	guile src/hello.scm 8084 &
	sleep 1
	curl -sf http://localhost:8084/healthz | grep -q '"status":"ok"'
	curl -sf http://localhost:8084/readyz | grep -q '"status":"ok"'
	curl -sf http://localhost:8084/health | grep -q '"status":"ok"'
	kill %1 2>/dev/null || true
	@echo "E2E passed"

fatbin:
	@echo "No fat binary support for Scheme"
	@echo "Consider Chicken Scheme (csc) for compiled binaries"

lint:
	@echo "No standard Scheme linter"

autoformat:
	@echo "No standard Scheme formatter"

format-check:
	@echo "No standard Scheme formatter"
