.PHONY: build clean test typecheck deps e2e fatbin lint autoformat format-check

deps:
	mix deps.get --quiet

build: deps
	MIX_ENV=prod mix compile

clean:
	rm -rf _build deps mix.lock

test: deps
	mix test --trace

typecheck: deps
	mix dialyzer

e2e: build
	@echo "E2E: testing via mix release..."
	MIX_ENV=prod mix release --overwrite --quiet
	_build/prod/rel/hello/bin/hello eval 'IO.puts(Hello.greet("E2E"))'  | grep -q "Hello, E2E!"
	@echo "E2E: PASS"

fatbin: deps
	MIX_ENV=prod mix release --overwrite
	@echo "Fat binary: _build/prod/rel/hello/"
	@du -sh _build/prod/rel/hello/

lint:
	mix credo 2>/dev/null || mix compile --warnings-as-errors

autoformat:
	mix format

format-check:
	mix format --check-formatted
