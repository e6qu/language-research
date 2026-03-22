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
	./target/release/hello-concurrency | grep -q "bytes"
	@echo "e2e passed"

fatbin:
	cargo build --release
	@ls -la target/release/hello-concurrency

lint:
	cargo clippy -- -D warnings

autoformat:
	cargo fmt

format-check:
	cargo fmt -- --check
