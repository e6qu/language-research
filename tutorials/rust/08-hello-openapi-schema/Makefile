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
	./target/release/hello-openapi-schema &
	sleep 1
	curl -s http://localhost:4052/api/openapi | python3 -c "import sys,json; d=json.load(sys.stdin); assert 'openapi' in d"
	pkill -f "target/release/hello" 2>/dev/null || true
	@echo "e2e passed"

fatbin:
	cargo build --release
	@ls -la target/release/hello-openapi-schema

lint:
	cargo clippy -- -D warnings

autoformat:
	cargo fmt

format-check:
	cargo fmt -- --check
