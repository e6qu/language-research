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
	./hello | grep -q "Fetching" && echo "PASS: concurrency demo ran"

fatbin:
	CGO_ENABLED=0 go build -ldflags="-s -w" -o hello ./...
	@ls -la hello
