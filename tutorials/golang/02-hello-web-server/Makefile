.PHONY: build clean test typecheck e2e fatbin lint autoformat format-check

build:
	CGO_ENABLED=0 go build -ldflags="-s -w" -o hello ./...

clean:
	rm -f hello
	go clean

test:
	go test -v ./...

typecheck:
	go vet ./...

e2e: build
	@lsof -ti:8080 | xargs kill 2>/dev/null || true
	@sleep 1
	./hello &
	@sleep 1
	curl -s http://localhost:8080/ | grep -q "Hello, World!" && echo "PASS: root"
	curl -s http://localhost:8080/greet/Gopher | grep -q "Hello, Gopher!" && echo "PASS: greet"
	curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/nope | grep -q "404" && echo "PASS: 404"
	@kill %1 2>/dev/null || true

fatbin:
	CGO_ENABLED=0 go build -ldflags="-s -w" -o hello ./...
	@ls -la hello

lint:
	go vet ./... && (staticcheck ./... 2>/dev/null || echo "Install staticcheck for extended linting")

autoformat:
	gofmt -w .

format-check:
	test -z "$$(gofmt -l .)" || { gofmt -l .; exit 1; }
