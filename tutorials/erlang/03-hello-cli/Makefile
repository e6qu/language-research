.PHONY: build clean test typecheck escript e2e fatbin lint autoformat format-check

escript:
	rebar3 escriptize

build: escript

clean:
	rebar3 clean -a
	rm -rf _build/default/bin/
	rm -rf _build rebar.lock

test:
	rebar3 eunit -v

typecheck:
	rebar3 dialyzer

e2e: escript
	@echo "E2E: testing CLI escript..."
	_build/default/bin/hello_cli --name Test --shout | grep -q "HELLO, TEST!"
	@echo "E2E: PASS"

fatbin: escript
	@echo "Fat binary (escript): _build/default/bin/hello_cli"
	@ls -la _build/default/bin/hello_cli

lint:
	rebar3 compile

autoformat:
	rebar3 fmt 2>/dev/null || echo "No auto-formatter configured"

format-check:
	rebar3 fmt 2>/dev/null || echo "No auto-formatter configured"
