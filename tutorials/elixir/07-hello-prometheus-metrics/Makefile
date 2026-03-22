.PHONY: build clean test typecheck deps release e2e fatbin

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

release: deps
	MIX_ENV=prod mix release --overwrite

e2e: build
	@echo "E2E: testing metrics server..."
	MIX_ENV=prod mix release --overwrite --quiet
	_build/prod/rel/hello_metrics/bin/hello_metrics daemon
	sleep 2
	curl -sf http://localhost:4001/work > /dev/null
	curl -sf http://localhost:4001/metrics | grep -q "hello"
	_build/prod/rel/hello_metrics/bin/hello_metrics stop || true
	@echo "E2E: PASS"

fatbin: deps
	MIX_ENV=prod mix release --overwrite
	@echo "Fat binary: _build/prod/rel/hello_metrics/"
	@du -sh _build/prod/rel/hello_metrics/
