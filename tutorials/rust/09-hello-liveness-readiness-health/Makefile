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
	./target/debug/hello-liveness-readiness-health &
	sleep 1
	curl -s http://localhost:4053/healthz | grep -q "alive"
	curl -s http://localhost:4053/readyz | grep -q "ready"
	curl -s http://localhost:4053/health | grep -q "healthy"
	kill %1
	@echo "e2e passed"

fatbin:
	cargo build --release
	@ls -la target/release/hello-liveness-readiness-health

lint:
	cargo clippy -- -D warnings

autoformat:
	cargo fmt

format-check:
	cargo fmt -- --check
