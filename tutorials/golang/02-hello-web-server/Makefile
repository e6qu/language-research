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
	curl -s http://localhost:8080/ | grep -q "Hello, World!" && echo "PASS: root"
	curl -s http://localhost:8080/greet/Gopher | grep -q "Hello, Gopher!" && echo "PASS: greet"
	curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/nope | grep -q "404" && echo "PASS: 404"
	@kill %1 2>/dev/null || true

fatbin:
	CGO_ENABLED=0 go build -ldflags="-s -w" -o hello ./...
	@ls -la hello
