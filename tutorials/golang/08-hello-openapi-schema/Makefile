.PHONY: build clean test typecheck e2e fatbin

build:
	go build -o hello ./...

clean:
	rm -f hello
	go clean

test:
	go test -v ./...

typecheck:
	go vet ./...

e2e: build
	./hello &
	@sleep 1
	curl -s http://localhost:8080/api/openapi | grep -q "openapi" && echo "PASS: openapi"
	curl -s http://localhost:8080/greet/Test | grep -q "Hello, Test!" && echo "PASS: greet"
	curl -s -X POST -d '{"name":"Bob"}' http://localhost:8080/greet | grep -q "Hello, Bob!" && echo "PASS: post greet"
	@kill %1 2>/dev/null || true

fatbin:
	CGO_ENABLED=0 go build -ldflags="-s -w" -o hello ./...
	@ls -la hello
