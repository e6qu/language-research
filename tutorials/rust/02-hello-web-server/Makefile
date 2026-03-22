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
	./target/debug/hello-web-server &
	sleep 1
	curl -s http://localhost:3000/ | grep -q "Hello, World!"
	curl -s http://localhost:3000/greet/Test | grep -q "Hello, Test!"
	curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/nope | grep -q "404"
	kill %1
	@echo "e2e passed"

fatbin:
	cargo build --release
	@ls -la target/release/hello-web-server
