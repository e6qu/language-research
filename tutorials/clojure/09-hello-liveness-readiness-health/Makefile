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
	@echo "Starting server on port 4029..."
	@lein run 4029 &
	@sleep 5
	@curl -sf http://localhost:4029/healthz | grep -q "alive" && echo "GET /healthz OK"
	@curl -sf http://localhost:4029/readyz | grep -q "ready" && echo "GET /readyz OK"
	@curl -sf http://localhost:4029/health | grep -q "healthy" && echo "GET /health OK"
	@pkill -f "hello-health.*4029" 2>/dev/null || true
	@echo "E2E: PASS"

fatbin:
	lein uberjar
	@echo "Fat JAR:"
	@ls -la target/uberjar/*-standalone.jar 2>/dev/null || ls -la target/*-standalone.jar
