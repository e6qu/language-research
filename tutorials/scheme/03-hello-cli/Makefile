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
	guile src/hello.scm --name "E2E" | grep -q "Hello, E2E!"
	guile src/hello.scm --greeting "Hi" --name "Test" | grep -q "Hi, Test!"
	@echo "E2E passed"

fatbin:
	@echo "No fat binary support for Scheme"
	@echo "Consider Chicken Scheme (csc) for compiled binaries"
