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
	./target/debug/hello-structured-logging 2>&1 | head -1 | python3 -c "import sys,json; json.load(sys.stdin)" && echo "e2e passed"

fatbin:
	cargo build --release
	@ls -la target/release/hello-structured-logging

lint:
	cargo clippy -- -D warnings

autoformat:
	cargo fmt

format-check:
	cargo fmt -- --check
