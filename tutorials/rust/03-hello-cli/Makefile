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
	./target/debug/hello-cli | grep -q "Hello, World!"
	./target/debug/hello-cli --name Rust | grep -q "Hello, Rust!"
	./target/debug/hello-cli --name Rust --shout | grep -q "HELLO, RUST!"
	@echo "e2e passed"

fatbin:
	cargo build --release
	@ls -la target/release/hello-cli

lint:
	cargo clippy -- -D warnings

autoformat:
	cargo fmt

format-check:
	cargo fmt -- --check
