.PHONY: build clean test typecheck e2e fatbin

build:
	wasm-pack build --target web

clean:
	cargo clean
	rm -rf pkg

test:
	cargo test

typecheck:
	cargo check

e2e: build
	@test -f pkg/hello_cli_bg.wasm
	@echo "E2E: WASM module built"
	@echo "E2E: PASS"

fatbin: build
	@echo "Fat binary (WASM):"
	@ls -la pkg/*.wasm
