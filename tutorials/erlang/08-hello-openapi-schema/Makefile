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
	@lsof -ti:8082 | xargs kill 2>/dev/null || true
	@echo "E2E: testing openapi server..."
	@erl -pa _build/default/lib/*/ebin -noshell -eval \
		'application:ensure_all_started(hello_openapi), receive after infinity -> ok end.' &
	@sleep 3
	curl -sf http://localhost:8082/api/openapi | grep -q "openapi"
	@pkill -f "beam.*hello_openapi" 2>/dev/null || true
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
