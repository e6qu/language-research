.PHONY: build clean test typecheck e2e fatbin

build:
	lein compile

clean:
	lein clean

test:
	lein test

typecheck:
	@echo "No static type checker (use clj-kondo for linting)"

e2e: build
	lein run | head -1 | python3 -c "import sys,json; d=json.load(sys.stdin); assert d['level']=='info'"
	@echo "E2E: PASS"

fatbin:
	lein uberjar
	@echo "Fat JAR:"
	@ls -la target/uberjar/*-standalone.jar 2>/dev/null || ls -la target/*-standalone.jar
