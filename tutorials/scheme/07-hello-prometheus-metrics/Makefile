.PHONY: build clean test typecheck e2e fatbin

build:
	@echo "Scheme is interpreted — no compilation step"

clean:
	rm -f *.out

test:
	guile test/run.scm

typecheck:
	guile -c '(load "src/hello.scm")' && echo "Syntax OK"

e2e: build
	guile src/hello.scm 8083 &
	sleep 1
	curl -sf http://localhost:8083/metrics | grep -q "http_requests_total"
	kill %1 2>/dev/null || true
	@echo "E2E passed"

fatbin:
	@echo "No fat binary support for Scheme"
	@echo "Consider Chicken Scheme (csc) for compiled binaries"
