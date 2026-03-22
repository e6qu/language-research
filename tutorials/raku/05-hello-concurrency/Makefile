.PHONY: build clean test typecheck e2e fatbin

build:
	raku -c lib/Concurrent.rakumod

clean:
	rm -rf .precomp

test:
	@for f in t/*.rakutest; do echo "--- $$f ---"; raku "$$f" || exit 1; done

typecheck:
	raku -c lib/Concurrent.rakumod

e2e: build
	raku bin/concurrent.raku | grep -q "Done"
	@echo "e2e passed"

fatbin:
	@echo "Raku does not have a mature fat binary tool"
	@echo "Use: raku --precompile for faster startup"
