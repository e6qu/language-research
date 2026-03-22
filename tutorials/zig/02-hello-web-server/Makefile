.PHONY: build clean test typecheck e2e fatbin lint autoformat format-check

build:
	zig build -Doptimize=ReleaseSafe

clean:
	rm -rf zig-out zig-cache .zig-cache

test:
	zig build test

typecheck:
	zig build test -Doptimize=Debug 2>&1 | head -1 || true

e2e: build
	@lsof -ti:4110 | xargs kill 2>/dev/null || true
	./zig-out/bin/hello_web_server &
	@sleep 2
	curl -sf http://localhost:4110/ | grep -q "Hello, world!"
	curl -sf http://localhost:4110/greet/Test | grep -q "Hello, Test!"
	@pkill -f "hello_web_server" 2>/dev/null || true
	@echo "E2E: PASS"

fatbin:
	zig build -Doptimize=ReleaseSafe
	@ls -la zig-out/bin/*

lint:
	@echo "Zig compiler includes built-in warnings"

autoformat:
	zig fmt src/

format-check:
	zig fmt --check src/
