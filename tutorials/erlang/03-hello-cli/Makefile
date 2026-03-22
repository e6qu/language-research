.PHONY: build clean test typecheck escript e2e fatbin

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
	_build/default/bin/hello_cli --name E2E --shout | grep -q "HELLO, E2E!"
	@echo "E2E: PASS"

fatbin: escript
	@echo "Fat binary (escript): _build/default/bin/hello_cli"
	@ls -la _build/default/bin/hello_cli
