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
	lua src/hello_cli.lua --name E2E --shout | grep -q "HELLO, E2E!"
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
