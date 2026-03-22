.PHONY: build clean test typecheck e2e fatbin

build:
	dub build

clean:
	dub clean
	rm -rf .dub

test:
	dub test

typecheck:
	dub build --build=syntax-only 2>/dev/null || dub build

e2e: build
	./hello

fatbin:
	dub build --build=release
	@ls -la hello 2>/dev/null || ls -la *app* 2>/dev/null
