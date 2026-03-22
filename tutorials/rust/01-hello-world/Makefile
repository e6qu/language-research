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
	./target/release/hello-world World | grep -q "Hello, World!"
	@echo "E2E: PASS"

fatbin:
	cargo build --release
	@ls -la target/release/hello-world

lint:
	cargo clippy -- -D warnings

autoformat:
	cargo fmt

format-check:
	cargo fmt -- --check
