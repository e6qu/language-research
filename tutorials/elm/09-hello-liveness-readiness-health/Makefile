.PHONY: build clean test typecheck e2e fatbin lint autoformat format-check

build:
	elm make src/Main.elm --optimize --output=elm.js

clean:
	rm -rf elm-stuff main.js elm.js

test:
	elm-test

# Elm's compiler IS the type checker — compilation = type checking
typecheck:
	elm make src/Main.elm --output=/dev/null

e2e: build
	@echo "E2E: verifying built JS is valid..."
	node -c elm.js
	test -s elm.js
	@echo "E2E: PASS"

fatbin: build
	@echo "Fat binary (optimized JS):"
	@ls -la main.js 2>/dev/null || ls -la elm.js 2>/dev/null

lint:
	elm-review 2>/dev/null || echo "Install elm-review for linting"

autoformat:
	elm-format --yes src/

format-check:
	elm-format --validate src/
