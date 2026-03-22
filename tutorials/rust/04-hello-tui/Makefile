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
	@echo "TUI requires interactive terminal; run manually with: cargo run"

fatbin:
	cargo build --release
	@ls -la target/release/hello-tui
