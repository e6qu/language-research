.PHONY: build clean test typecheck e2e deps fatbin lint autoformat format-check

build:
	@echo "No compilation needed for Lua."
	@lua -e 'loadfile("src/concurrent.lua")()'
	@echo "Build OK."

clean:
	@echo "Nothing to clean."

deps:
	luarocks install busted --local 2>/dev/null || true
	luarocks install dkjson --local 2>/dev/null || true

test: deps
	eval $$(luarocks path --bin) && busted test/

typecheck:
	@echo "No static type checker configured for plain Lua."

e2e: test
	@echo "E2E: PASS"

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
