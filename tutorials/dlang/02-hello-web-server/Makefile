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
	./hello-web-server &
	sleep 1
	curl -s http://localhost:8080/ | grep -q "Hello, world!" && echo "PASS: /" || echo "FAIL: /"
	curl -s http://localhost:8080/health | grep -q "ok" && echo "PASS: /health" || echo "FAIL: /health"
	kill %1 2>/dev/null || true

fatbin:
	dub build --build=release
	@ls -la hello-web-server 2>/dev/null || ls -la *app* 2>/dev/null
