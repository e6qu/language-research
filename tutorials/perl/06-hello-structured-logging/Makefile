.PHONY: build clean test typecheck e2e fatbin lint autoformat format-check

build:
	perl -c lib/Logger.pm

clean:
	rm -f *.out

test:
	prove -v t/

typecheck:
	perl -c lib/Logger.pm

e2e: build
	perl -Ilib -MLogger -e 'print Logger::info("hello"), "\n"' | python3 -c "import sys,json; json.load(sys.stdin)"
	@echo "e2e passed"

fatbin:
	@echo "Install PAR::Packer for fat binaries: cpan PAR::Packer"
	@echo "Then: pp -o logger lib/Logger.pm"

lint:
	perl -cw lib/*.pm

autoformat:
	perltidy -b lib/*.pm bin/*.pl 2>/dev/null; true

format-check:
	perltidy -st lib/*.pm 2>/dev/null | diff -q - lib/*.pm > /dev/null || echo "Needs formatting"
