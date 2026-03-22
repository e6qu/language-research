.PHONY: build clean test typecheck deps e2e fatbin

deps:
	mix deps.get --quiet

build: deps
	mix compile

clean:
	rm -rf _build deps mix.lock

test: deps
	mix test --trace

typecheck: deps
	mix dialyzer

e2e: build
	@echo "E2E: testing structured logging..."
	mix run -e 'HelloLogging.demo()' 2>&1 | head -1 | python3 -c "import sys,json; json.load(sys.stdin); print('valid JSON')"
	@echo "E2E: PASS"

fatbin: deps
	MIX_ENV=prod mix release --overwrite
	@echo "Fat binary: _build/prod/rel/hello_logging/"
	@du -sh _build/prod/rel/hello_logging/
