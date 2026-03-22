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
	./target/debug/hello-openapi-schema &
	sleep 1
	curl -s http://localhost:3000/api/openapi | python3 -c "import sys,json; d=json.load(sys.stdin); assert 'openapi' in d"
	kill %1
	@echo "e2e passed"

fatbin:
	cargo build --release
	@ls -la target/release/hello-openapi-schema
