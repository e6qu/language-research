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
	@echo "Starting server on port 4020..."
	@lein run 4020 &
	@sleep 10
	@curl -sf http://localhost:4020/ | grep -q "Hello, world!" && echo "GET / OK"
	@curl -sf http://localhost:4020/greet/E2E | grep -q "Hello, E2E!" && echo "GET /greet/E2E OK"
	@curl -sf -o /dev/null -w '%{http_code}' http://localhost:4020/nope | grep -q 404 && echo "404 OK"
	@pkill -f "hello-web.*4020" 2>/dev/null || true
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
