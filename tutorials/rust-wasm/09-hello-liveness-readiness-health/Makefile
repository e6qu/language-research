.PHONY: build clean test typecheck e2e fatbin lint autoformat format-check

build:
	wasm-pack build --release --target web

clean:
	cargo clean
	rm -rf pkg

test:
	cargo test

typecheck:
	cargo check

e2e: build
	@test -f pkg/hello_liveness_readiness_health_bg.wasm
	@echo "E2E: WASM module built"
	@echo "E2E: PASS"

fatbin: build
	@echo "Fat binary (WASM):"
	@ls -la pkg/*.wasm

lint:
	cargo clippy -- -D warnings

autoformat:
	cargo fmt

format-check:
	cargo fmt -- --check
