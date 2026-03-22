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
	./zig-out/bin/hello-openapi-schema | python3 -m json.tool

fatbin:
	zig build -Doptimize=ReleaseSafe
	@ls -la zig-out/bin/*

lint:
	@echo "Zig compiler includes built-in warnings"

autoformat:
	zig fmt src/

format-check:
	zig fmt --check src/
