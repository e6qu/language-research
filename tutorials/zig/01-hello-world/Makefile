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
	./zig-out/bin/hello
	./zig-out/bin/hello Zig

fatbin:
	zig build -Doptimize=ReleaseSafe
	@ls -la zig-out/bin/*
