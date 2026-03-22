.PHONY: build clean test typecheck e2e fatbin

build:
	raku -c lib/Logger.rakumod

clean:
	rm -rf .precomp

test:
	@for f in t/*.rakutest; do echo "--- $$f ---"; raku "$$f" || exit 1; done

typecheck:
	raku -c lib/Logger.rakumod

e2e: build
	raku bin/logger.raku | python3 -c "import sys,json; [json.loads(l) for l in sys.stdin]"
	@echo "e2e passed"

fatbin:
	@echo "Raku does not have a mature fat binary tool"
	@echo "Use: raku --precompile for faster startup"
