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
	@lsof -ti:4060 | xargs kill 2>/dev/null || true
	./hello &
	@sleep 2
	curl -sf http://localhost:4060/ | grep -q "Hello, world!"
	curl -sf http://localhost:4060/greet/Test | grep -q "Hello, Test!"
	@pkill -f "./hello" 2>/dev/null || true
	@echo "E2E: PASS"

fatbin:
	CGO_ENABLED=0 go build -ldflags="-s -w" -o hello ./...
	@ls -la hello

lint:
	go vet ./... && (staticcheck ./... 2>/dev/null || echo "Install staticcheck for extended linting")

autoformat:
	gofmt -w .

format-check:
	test -z "$$(gofmt -l .)" || { gofmt -l .; exit 1; }
