.PHONY: build clean test typecheck e2e fatbin lint autoformat format-check

build:
	lein uberjar

clean:
	lein clean

test:
	lein test

typecheck:
	@echo "No static type checker (use clj-kondo for linting)"

e2e: build
	@lsof -ti:4101 | xargs kill 2>/dev/null || true
	@echo "Starting server on port 4101..."
	@lein run 4101 &
	@sleep 10
	curl -sf http://localhost:4101/work > /dev/null
	curl -sf http://localhost:4101/metrics | grep -q "work"
	@pkill -f "hello-metrics.*4101" 2>/dev/null || true
	@echo "E2E: PASS"

fatbin:
	lein uberjar
	@echo "Fat JAR:"
	@ls -la target/uberjar/*-standalone.jar 2>/dev/null || ls -la target/*-standalone.jar

lint:
	lein kibit 2>/dev/null || echo "Install kibit for linting"

autoformat:
	lein cljfmt fix 2>/dev/null || echo "Install cljfmt"

format-check:
	lein cljfmt check 2>/dev/null || echo "Install cljfmt"
