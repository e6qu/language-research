.PHONY: build clean test typecheck e2e fatbin

build:
	raku -c lib/HealthChecker.rakumod

clean:
	rm -rf .precomp

test:
	@for f in t/*.rakutest; do echo "--- $$f ---"; raku "$$f" || exit 1; done

typecheck:
	raku -c lib/HealthChecker.rakumod

e2e: build
	raku bin/health.raku | grep -q '"status":"ok"'
	@echo "e2e passed"

fatbin:
	@echo "Raku does not have a mature fat binary tool"
	@echo "Use: raku --precompile for faster startup"
