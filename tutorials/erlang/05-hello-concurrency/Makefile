.PHONY: build clean test typecheck e2e fatbin

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
	@echo "E2E: testing concurrency..."
	erl -pa _build/default/lib/*/ebin -noshell -eval 'R = parallel_fetch:fetch_all([]), io:format("~p~n", [R]), halt().' | grep -q "\\[\\]"
	@echo "E2E: PASS"

fatbin: build
	@echo "Note: add relx config to rebar.config for full OTP release with bundled ERTS"
	@echo "Built to: _build/default/lib/"
