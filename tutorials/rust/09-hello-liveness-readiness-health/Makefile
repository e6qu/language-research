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
	@lsof -ti:4053 | xargs kill 2>/dev/null || true
	./target/release/hello-liveness-readiness-health &
	@sleep 2
	curl -sf http://localhost:4053/healthz | grep -q "status"
	@pkill -f "target/release/hello" 2>/dev/null || true
	@echo "E2E: PASS"

fatbin:
	cargo build --release
	@ls -la target/release/hello-liveness-readiness-health

lint:
	cargo clippy -- -D warnings

autoformat:
	cargo fmt

format-check:
	cargo fmt -- --check
