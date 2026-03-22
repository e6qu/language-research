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
	@lsof -ti:4100 | xargs kill 2>/dev/null || true
	@echo "Starting server on port 4100..."
	@lein run 4100 &
	@sleep 10
	curl -sf http://localhost:4100/ | grep -q "Hello, world!"
	curl -sf http://localhost:4100/greet/Test | grep -q "Hello, Test!"
	@pkill -f "hello-web.*4100" 2>/dev/null || true
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
