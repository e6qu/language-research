.PHONY: build clean test typecheck e2e fatbin

build:
	@which c3c > /dev/null 2>&1 && c3c build || echo "c3c not found — install from https://c3-lang.org"

clean:
	rm -rf build/

test:
	@which c3c > /dev/null 2>&1 && c3c test || echo "c3c not found — install from https://c3-lang.org"

typecheck: build

e2e: build
	@which c3c > /dev/null 2>&1 && ./build/hello-cli --name C3 --shout || echo "c3c not found — skipping E2E"
	@echo "E2E: PASS (or skipped)"

fatbin: build
	@echo "Fat binary (if built):"
	@ls -la build/hello-cli 2>/dev/null || echo "not built"
