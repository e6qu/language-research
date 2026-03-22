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
	@lsof -ti:4002 | xargs kill 2>/dev/null || true
	@echo "E2E: testing OpenAPI server..."
	MIX_ENV=prod mix release --overwrite --quiet
	_build/prod/rel/hello_openapi/bin/hello_openapi daemon
	@sleep 2
	curl -sf http://localhost:4002/api/openapi | grep -q "openapi"
	_build/prod/rel/hello_openapi/bin/hello_openapi stop || true
	@echo "E2E: PASS"

fatbin: deps
	MIX_ENV=prod mix release --overwrite
	@echo "Fat binary: _build/prod/rel/hello_openapi/"
	@du -sh _build/prod/rel/hello_openapi/

lint:
	mix credo 2>/dev/null || mix compile --warnings-as-errors

autoformat:
	mix format

format-check:
	mix format --check-formatted
