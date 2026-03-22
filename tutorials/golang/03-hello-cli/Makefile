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
	./hello -name Test -shout | grep -q "HELLO, TEST!"
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
