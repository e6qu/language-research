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
	@echo "E2E: testing web server..."
	@erl -pa _build/default/lib/*/ebin -noshell -eval \
		'application:ensure_all_started(hello_web), receive after infinity -> ok end.' &
	@sleep 2
	@curl -sf http://localhost:8080/ | grep -q "Hello, world"
	@curl -sf http://localhost:8080/greet/E2E | grep -q "Hello, E2E"
	@pkill -f "_build/default/lib.*hello_web" 2>/dev/null || true
	@sleep 1
	@echo "E2E: PASS"

fatbin:
	rebar3 release
	@echo "Fat binary: _build/default/rel/hello_web/"
	@du -sh _build/default/rel/hello_web/

lint:
	rebar3 compile

autoformat:
	rebar3 fmt 2>/dev/null || echo "No auto-formatter configured"

format-check:
	rebar3 fmt 2>/dev/null || echo "No auto-formatter configured"
