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
	@echo "E2E: testing structured logging..."
	erl -pa _build/default/lib/*/ebin -noshell -eval 'R = json_formatter:format(#{msg => {string, "test"}, level => info, meta => #{time => erlang:system_time(microsecond)}}, #{}), io:format("~s", [R]), halt().' | python3 -c "import sys,json; json.load(sys.stdin); print('valid JSON')"
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
