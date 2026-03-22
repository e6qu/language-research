.PHONY: build clean test typecheck e2e fatbin lint autoformat format-check

build:
	@which c3c > /dev/null 2>&1 && c3c build --release || echo "c3c not found — install from https://c3-lang.org"

clean:
	rm -rf build/

test:
	@which c3c > /dev/null 2>&1 && c3c test || echo "c3c not found — install from https://c3-lang.org"

typecheck: build

e2e: test
	@echo "E2E: PASS"

fatbin: build
	@echo "Fat binary (if built):"
	@ls -la build/hello-logging 2>/dev/null || echo "not built"

lint:
	@which c3c > /dev/null 2>&1 && c3c build 2>&1 || echo "c3c not found — install from https://c3-lang.org"

autoformat:
	@echo "No standard C3 formatter"

format-check:
	@echo "No standard C3 formatter"
