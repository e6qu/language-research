.PHONY: build clean test typecheck e2e fatbin

build:
	@echo "Lua is interpreted — no compilation step"

clean:
	rm -f *.out

test:
	eval $$(luarocks path --bin) && busted test/

typecheck:
	@echo "No static type checker configured (install teal for type checking)"

e2e: build
	lua -e 'h=require("src.hello"); print(h.greet("E2E"))' | grep -q "Hello, E2E!"
	@echo "e2e passed"

LUA_STATIC_LIB = /opt/homebrew/lib/liblua.a
LUA_INCLUDE = /opt/homebrew/include/lua

fatbin:
	luastatic bin/main.lua src/*.lua $(LUA_STATIC_LIB) -I$(LUA_INCLUDE)
	@echo "Fat binary:"
	@ls -la main
	@du -h main
