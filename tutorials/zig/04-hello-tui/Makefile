.PHONY: build clean test typecheck e2e fatbin

build:
	zig build

clean:
	rm -rf zig-out zig-cache .zig-cache

test:
	zig build test

typecheck:
	zig build test -Doptimize=Debug 2>&1 | head -1 || true

e2e: build
	@echo "Run interactively: ./zig-out/bin/hello-tui"

fatbin:
	zig build -Doptimize=ReleaseSafe
	@ls -la zig-out/bin/*
