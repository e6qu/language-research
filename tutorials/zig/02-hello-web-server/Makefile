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
	./zig-out/bin/hello-web-server &
	sleep 1
	curl -s http://127.0.0.1:8080/ | python3 -m json.tool
	curl -s http://127.0.0.1:8080/greet/Zig | python3 -m json.tool
	curl -s http://127.0.0.1:8080/unknown | python3 -m json.tool
	kill %1 || true

fatbin:
	zig build -Doptimize=ReleaseSafe
	@ls -la zig-out/bin/*
