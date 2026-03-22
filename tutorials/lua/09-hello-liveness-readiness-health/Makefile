.PHONY: build clean test typecheck e2e deps fatbin

build:
	@echo "No build step required for Lua"

clean:
	@rm -rf luac.out *.o

test:
	eval $$(luarocks path --bin) && busted test/

typecheck:
	@echo "No static type checker configured"

e2e:
	lua -e 'h=require("src.health_checker"); h.init(); print(h.status())' | grep -q "ok"
	@echo "e2e passed"

LUA_STATIC_LIB = /opt/homebrew/lib/liblua.a
LUA_INCLUDE = /opt/homebrew/include/lua

fatbin:
	luastatic bin/main.lua src/*.lua $(LUA_STATIC_LIB) -I$(LUA_INCLUDE)
	@echo "Fat binary:"
	@ls -la main
	@du -h main

deps:
	luarocks install busted --local 2>/dev/null || true
	luarocks install dkjson --local 2>/dev/null || true
	luarocks install luasocket --local 2>/dev/null || true
