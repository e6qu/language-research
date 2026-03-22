.PHONY: build clean test typecheck e2e fatbin lint autoformat format-check

PORT ?= 4040

build:
	raku -c lib/Server.rakumod

clean:
	rm -rf .precomp

test:
	@for f in t/*.rakutest; do echo "--- $$f ---"; raku "$$f" || exit 1; done

typecheck:
	raku -c lib/Server.rakumod

e2e: build
	@lsof -ti:$(PORT) | xargs kill 2>/dev/null || true
	raku bin/server.raku $(PORT) &
	@sleep 2
	curl -sf http://localhost:$(PORT)/ | grep -q "Hello, world!"
	curl -sf http://localhost:$(PORT)/greet/Test | grep -q "Hello, Test!"
	@pkill -f "raku.*server" 2>/dev/null || true
	@echo "E2E: PASS"

fatbin:
	@echo "Raku does not have a mature fat binary tool"
	@echo "Use: raku --precompile for faster startup"

lint:
	raku -c lib/*.rakumod

autoformat:
	@echo "No standard Raku formatter"

format-check:
	@echo "No standard Raku formatter"
