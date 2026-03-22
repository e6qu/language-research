.PHONY: build clean test typecheck e2e fatbin lint autoformat format-check

build:
	perl -c lib/HelloCli.pm

clean:
	rm -f *.out hello_cli

test:
	prove -v t/

typecheck:
	perl -c lib/HelloCli.pm

e2e: build
	perl -Ilib bin/hello_cli.pl --name E2E --shout | grep -q "HELLO, E2E!"
	@echo "e2e passed"

fatbin:
	@echo "Install PAR::Packer for fat binaries: cpan PAR::Packer"
	@echo "Then: pp -o hello_cli bin/hello_cli.pl"

lint:
	perl -cw lib/*.pm

autoformat:
	perltidy -b lib/*.pm bin/*.pl 2>/dev/null; true

format-check:
	perltidy -st lib/*.pm 2>/dev/null | diff -q - lib/*.pm > /dev/null || echo "Needs formatting"
