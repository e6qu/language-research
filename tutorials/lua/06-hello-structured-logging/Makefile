.PHONY: build clean test typecheck e2e deps fatbin

build:
	@echo "No compilation needed for Lua."
	@eval $$(luarocks path --bin 2>/dev/null) || true
	@lua -e 'require("dkjson")' && echo "dkjson available."
	@lua -e 'loadfile("src/logger.lua")'
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

e2e: deps
	bash e2e/e2e_test.sh

LUA_STATIC_LIB = /opt/homebrew/lib/liblua.a
LUA_INCLUDE = /opt/homebrew/include/lua

fatbin:
	luastatic bin/main.lua src/*.lua $(LUA_STATIC_LIB) -I$(LUA_INCLUDE)
	@echo "Fat binary:"
	@ls -la main
	@du -h main
