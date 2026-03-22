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
	./hello | head -1 | python3 -c "import sys,json; json.load(sys.stdin); print('PASS: valid JSON output')"

fatbin:
	CGO_ENABLED=0 go build -ldflags="-s -w" -o hello ./...
	@ls -la hello
