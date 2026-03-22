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
	curl -s http://localhost:8080/work > /dev/null
	curl -s http://localhost:8080/work > /dev/null
	curl -s http://localhost:8080/metrics | grep -q "work_total" && echo "PASS: metrics"
	@kill %1 2>/dev/null || true

fatbin:
	CGO_ENABLED=0 go build -ldflags="-s -w" -o hello ./...
	@ls -la hello
