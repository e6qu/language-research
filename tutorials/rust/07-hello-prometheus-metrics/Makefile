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
	./target/release/hello-prometheus-metrics &
	sleep 1
	curl -s -X POST http://localhost:4051/work
	curl -s http://localhost:4051/metrics | grep -q "work_total"
	kill %1
	@echo "e2e passed"

fatbin:
	cargo build --release
	@ls -la target/release/hello-prometheus-metrics

lint:
	cargo clippy -- -D warnings

autoformat:
	cargo fmt

format-check:
	cargo fmt -- --check
