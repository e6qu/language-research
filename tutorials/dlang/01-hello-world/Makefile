.PHONY: build clean test typecheck e2e fatbin

build:
	ldc2 -of=hello source/app.d source/hello.d

clean:
	rm -f hello *.o

test:
	ldc2 -unittest -main -run source/hello.d

typecheck:
	ldc2 -o- source/hello.d source/app.d

e2e: build
	./hello | head -1 | grep -qi "hello"
	@echo "E2E: PASS"

fatbin:
	ldc2 -O2 -of=hello source/app.d source/hello.d
	@ls -la hello
