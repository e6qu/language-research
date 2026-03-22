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
	./target/debug/hello-prometheus-metrics &
	sleep 1
	curl -s -X POST http://localhost:3000/work
	curl -s http://localhost:3000/metrics | grep -q "work_total"
	kill %1
	@echo "e2e passed"

fatbin:
	cargo build --release
	@ls -la target/release/hello-prometheus-metrics
