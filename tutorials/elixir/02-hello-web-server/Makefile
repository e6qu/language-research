.PHONY: build clean test typecheck deps release e2e fatbin lint autoformat format-check

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

release: deps
	MIX_ENV=prod mix release --overwrite

e2e: build
	@echo "E2E: testing web server..."
	MIX_ENV=prod mix release --overwrite --quiet
	_build/prod/rel/hello_web/bin/hello_web daemon
	sleep 2
	curl -sf http://localhost:4000/ | grep -q "Hello, world"
	curl -sf http://localhost:4000/greet/E2E | grep -q "Hello, E2E"
	_build/prod/rel/hello_web/bin/hello_web stop || true
	@echo "E2E: PASS"

fatbin: deps
	MIX_ENV=prod mix release --overwrite
	@echo "Fat binary: _build/prod/rel/hello_web/"
	@du -sh _build/prod/rel/hello_web/

lint:
	mix credo 2>/dev/null || mix compile --warnings-as-errors

autoformat:
	mix format

format-check:
	mix format --check-formatted
