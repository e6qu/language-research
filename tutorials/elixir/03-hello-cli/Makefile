.PHONY: build clean test typecheck deps escript release e2e fatbin lint autoformat format-check

deps:
	mix deps.get --quiet

escript: deps
	mix escript.build

release: deps
	MIX_ENV=prod mix release --overwrite

build: deps escript
	MIX_ENV=prod mix compile

clean:
	rm -rf _build deps mix.lock
	rm -f hello_cli

test: deps
	mix test --trace

typecheck: deps
	mix dialyzer

e2e: escript
	@echo "E2E: testing CLI escript..."
	./hello_cli --name E2E --shout | grep -q "HELLO, E2E!"
	./hello_cli --name World | grep -q "Hello, World!"
	@echo "E2E: PASS"

fatbin: deps
	MIX_ENV=prod mix release --overwrite
	@echo "Fat binary: _build/prod/rel/hello_cli/"
	@du -sh _build/prod/rel/hello_cli/

lint:
	mix credo 2>/dev/null || mix compile --warnings-as-errors

autoformat:
	mix format

format-check:
	mix format --check-formatted
