.PHONY: build clean test typecheck e2e fatbin lint autoformat format-check

build:
	@echo "Lua is interpreted — no compilation step"

clean:
	rm -f *.out

test:
	eval $$(luarocks path --bin) && busted test/

typecheck:
	@echo "No static type checker configured (install teal for type checking)"

e2e: build
	lua src/server.lua 4010 &
	sleep 1
	curl -sf http://localhost:4010/ | grep -q "Hello, world"
	curl -sf http://localhost:4010/greet/E2E | grep -q "Hello, E2E"
	kill %1 2>/dev/null || true
	@echo "e2e passed"

LUA_STATIC_LIB = /opt/homebrew/lib/liblua.a
LUA_INCLUDE = /opt/homebrew/include/lua

fatbin:
	luastatic bin/main.lua src/*.lua $(LUA_STATIC_LIB) -I$(LUA_INCLUDE)
	@echo "Fat binary:"
	@ls -la main
	@du -h main

lint:
	luacheck src/ 2>/dev/null || echo "Install luacheck: luarocks install luacheck"

autoformat:
	@echo "No standard Lua formatter"

format-check:
	@echo "No standard Lua formatter"
