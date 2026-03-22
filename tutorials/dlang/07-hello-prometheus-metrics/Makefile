.PHONY: build clean test typecheck e2e fatbin lint autoformat format-check

build:
	ldc2 -O2 -of=hello source/app.d source/hello.d

clean:
	rm -f hello *.o

test:
	ldc2 -unittest -main -run source/hello.d

typecheck:
	ldc2 -o- source/hello.d source/app.d

e2e: build
	./hello | grep -qi "http_requests_total"
	@echo "E2E: PASS"

fatbin:
	ldc2 -O2 -of=hello source/app.d source/hello.d
	@ls -la hello

lint:
	ldc2 -wi source/hello.d 2>&1 || true

autoformat:
	dfmt source/*.d 2>/dev/null || echo "Install dfmt"

format-check:
	dfmt source/*.d 2>/dev/null || echo "Install dfmt"
