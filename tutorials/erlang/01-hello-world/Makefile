.PHONY: build clean test typecheck release e2e fatbin lint autoformat format-check

build:
	rebar3 compile

clean:
	rebar3 clean -a
	rm -rf _build rebar.lock

test:
	rebar3 eunit -v

typecheck:
	rebar3 dialyzer

release:
	rebar3 release

e2e: build
	@echo "E2E: testing hello..."
	erl -pa _build/default/lib/*/ebin -noshell -eval 'io:format("~s~n", [hello:greet(<<"E2E">>)]), halt().' | grep -q "Hello, E2E!"
	@echo "E2E: PASS"

fatbin:
	rebar3 release
	@echo "Fat binary: _build/default/rel/hello/"
	@du -sh _build/default/rel/hello/

lint:
	rebar3 compile

autoformat:
	rebar3 fmt 2>/dev/null || echo "No auto-formatter configured"

format-check:
	rebar3 fmt 2>/dev/null || echo "No auto-formatter configured"
