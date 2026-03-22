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
	@echo "E2E: testing metrics..."
	erl -pa _build/default/lib/*/ebin -noshell -eval 'application:ensure_all_started(prometheus), prometheus_counter:new([{name,test_e2e},{help,"e2e"}]), prometheus_counter:inc(test_e2e), V = prometheus_counter:value(test_e2e), io:format("~p~n",[V]), halt().' | grep -q "1"
	@echo "E2E: PASS"

fatbin: build
	@echo "Note: add relx config to rebar.config for full OTP release with bundled ERTS"
	@echo "Built to: _build/default/lib/"
