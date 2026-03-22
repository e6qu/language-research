.PHONY: build clean test typecheck e2e fatbin

build:
	cargo build

clean:
	cargo clean

test:
	cargo test

typecheck:
	cargo check

e2e: build
	./target/debug/hello-world | grep -q "Hello, World!"
	@echo "e2e passed"

fatbin:
	cargo build --release
	@ls -la target/release/hello-world
