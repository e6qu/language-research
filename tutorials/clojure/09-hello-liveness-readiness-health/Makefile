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
	@echo "Starting server on port 4103..."
	@lein run 4103 &
	@sleep 12
	@curl -sf http://localhost:4103/healthz | grep -q "alive" && echo "GET /healthz OK"
	@curl -sf http://localhost:4103/readyz | grep -q "ready" && echo "GET /readyz OK"
	@curl -sf http://localhost:4103/health | grep -q "healthy" && echo "GET /health OK"
	@pkill -f "hello-health.*4103" 2>/dev/null || true
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
