.PHONY: build clean test typecheck e2e fatbin

build:
	dub build

clean:
	dub clean
	rm -rf .dub

test:
	dub test

typecheck:
	dub build --build=syntax-only 2>/dev/null || dub build

e2e: build
	./hello-liveness-readiness-health &
	sleep 1
	curl -s http://localhost:8080/livez | grep -q "alive" && echo "PASS: /livez" || echo "FAIL: /livez"
	curl -s http://localhost:8080/readyz | grep -q "ready" && echo "PASS: /readyz" || echo "FAIL: /readyz"
	curl -s http://localhost:8080/healthz | grep -q "alive" && echo "PASS: /healthz" || echo "FAIL: /healthz"
	kill %1 2>/dev/null || true

fatbin:
	dub build --build=release
	@ls -la hello-liveness-readiness-health 2>/dev/null || ls -la *app* 2>/dev/null
