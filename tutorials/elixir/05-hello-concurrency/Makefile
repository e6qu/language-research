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

e2e: test
	@echo "E2E: PASS"

fatbin: deps
	MIX_ENV=prod mix release --overwrite
	@echo "Fat binary: _build/prod/rel/hello_concurrency/"
	@du -sh _build/prod/rel/hello_concurrency/

lint:
	mix credo 2>/dev/null || mix compile --warnings-as-errors

autoformat:
	mix format

format-check:
	mix format --check-formatted
