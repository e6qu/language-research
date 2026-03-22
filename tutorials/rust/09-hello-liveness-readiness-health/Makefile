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
	./target/debug/hello-liveness-readiness-health &
	sleep 1
	curl -s http://localhost:3000/healthz | grep -q "alive"
	curl -s http://localhost:3000/readyz | grep -q "ready"
	curl -s http://localhost:3000/health | grep -q "healthy"
	kill %1
	@echo "e2e passed"

fatbin:
	cargo build --release
	@ls -la target/release/hello-liveness-readiness-health
