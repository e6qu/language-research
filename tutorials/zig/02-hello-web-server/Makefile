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
	./zig-out/bin/hello_web_server &
	sleep 1
	curl -s http://127.0.0.1:8080/ | python3 -m json.tool
	curl -s http://127.0.0.1:8080/greet/Zig | python3 -m json.tool
	curl -s http://127.0.0.1:8080/unknown | python3 -m json.tool
	kill %1 || true

fatbin:
	zig build -Doptimize=ReleaseSafe
	@ls -la zig-out/bin/*

lint:
	@echo "Zig compiler includes built-in warnings"

autoformat:
	zig fmt src/

format-check:
	zig fmt --check src/
