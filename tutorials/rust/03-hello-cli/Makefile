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
	./target/debug/hello-cli | grep -q "Hello, World!"
	./target/debug/hello-cli --name Rust | grep -q "Hello, Rust!"
	./target/debug/hello-cli --name Rust --shout | grep -q "HELLO, RUST!"
	@echo "e2e passed"

fatbin:
	cargo build --release
	@ls -la target/release/hello-cli
