.PHONY: build clean test typecheck e2e fatbin

build:
	raku -c lib/HelloCli.rakumod

clean:
	rm -rf .precomp

test:
	@for f in t/*.rakutest; do echo "--- $$f ---"; raku "$$f" || exit 1; done

typecheck:
	raku -c lib/HelloCli.rakumod

e2e: build
	raku bin/hello-cli.raku --name E2E --shout | grep -q "HELLO, E2E!"
	@echo "e2e passed"

fatbin:
	@echo "Raku does not have a mature fat binary tool"
	@echo "Use: raku --precompile for faster startup"
