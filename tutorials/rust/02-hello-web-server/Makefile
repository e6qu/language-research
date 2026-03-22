.PHONY: build clean test typecheck e2e fatbin lint autoformat format-check

build:
	cargo build --release

clean:
	cargo clean

test:
	cargo test

typecheck:
	cargo check

e2e: build
	./target/release/hello-web-server &
	sleep 1
	curl -s http://localhost:4050/ | grep -q "Hello, World!"
	curl -s http://localhost:4050/greet/Test | grep -q "Hello, Test!"
	curl -s -o /dev/null -w "%{http_code}" http://localhost:4050/nope | grep -q "404"
	pkill -f "target/release/hello" 2>/dev/null || true
	@echo "e2e passed"

fatbin:
	cargo build --release
	@ls -la target/release/hello-web-server

lint:
	cargo clippy -- -D warnings

autoformat:
	cargo fmt

format-check:
	cargo fmt -- --check
