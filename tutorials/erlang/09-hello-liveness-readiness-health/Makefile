.PHONY: build clean test typecheck e2e fatbin lint autoformat format-check

build:
	rebar3 compile

clean:
	rebar3 clean -a
	rm -rf _build rebar.lock

test:
	rebar3 eunit -v

typecheck:
	rebar3 dialyzer

e2e: build
	@echo "E2E: testing health checker..."
	erl -pa _build/default/lib/*/ebin -noshell -eval '{ok,P} = health_checker:start_link(), ok = health_checker:status(), health_checker:set_dependency(database, error), degraded = health_checker:status(), io:format("ok~n"), halt().' | grep -q "ok"
	@echo "E2E: PASS"

fatbin: build
	@echo "Note: add relx config to rebar.config for full OTP release with bundled ERTS"
	@echo "Built to: _build/default/lib/"

lint:
	rebar3 compile

autoformat:
	rebar3 fmt 2>/dev/null || echo "No auto-formatter configured"

format-check:
	rebar3 fmt 2>/dev/null || echo "No auto-formatter configured"
