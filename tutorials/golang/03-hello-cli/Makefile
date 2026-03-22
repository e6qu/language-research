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
	./hello | grep -q "Hello, World!" && echo "PASS: default"
	./hello -name Gopher | grep -q "Hello, Gopher!" && echo "PASS: name"
	./hello -name Go -shout | grep -q "HELLO, GO!" && echo "PASS: shout"

fatbin:
	CGO_ENABLED=0 go build -ldflags="-s -w" -o hello ./...
	@ls -la hello
