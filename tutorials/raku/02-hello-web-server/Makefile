.PHONY: build clean test typecheck e2e fatbin

PORT ?= 8082

build:
	raku -c lib/Server.rakumod

clean:
	rm -rf .precomp

test:
	@for f in t/*.rakutest; do echo "--- $$f ---"; raku "$$f" || exit 1; done

typecheck:
	raku -c lib/Server.rakumod

e2e: build
	raku bin/server.raku $(PORT) &
	sleep 1
	curl -s http://localhost:$(PORT)/ | grep -q "Hello, world!" && echo "e2e root passed"
	curl -s http://localhost:$(PORT)/greet/E2E | grep -q "Hello, E2E!" && echo "e2e greet passed"
	kill %1 2>/dev/null || true

fatbin:
	@echo "Raku does not have a mature fat binary tool"
	@echo "Use: raku --precompile for faster startup"
