.PHONY: build clean test typecheck e2e fatbin lint autoformat format-check

build:
	raku -c lib/Metrics.rakumod

clean:
	rm -rf .precomp

test:
	@for f in t/*.rakutest; do echo "--- $$f ---"; raku "$$f" || exit 1; done

typecheck:
	raku -c lib/Metrics.rakumod

e2e: build
	raku bin/metrics.raku | grep -q "http_requests_total"
	@echo "e2e passed"

fatbin:
	@echo "Raku does not have a mature fat binary tool"
	@echo "Use: raku --precompile for faster startup"

lint:
	raku -c lib/*.rakumod

autoformat:
	@echo "No standard Raku formatter"

format-check:
	@echo "No standard Raku formatter"
