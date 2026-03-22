.PHONY: build clean test typecheck e2e fatbin lint autoformat format-check

build:
	perl -c lib/Server.pm

clean:
	rm -f *.out

test:
	prove -v t/

typecheck:
	perl -c lib/Server.pm

e2e: build
	@lsof -ti:4030 | xargs kill 2>/dev/null || true
	perl -Ilib -MServer -e 'Server::start(4030)' &
	@sleep 2
	curl -sf http://localhost:4030/ | grep -q "Hello, world!"
	curl -sf http://localhost:4030/greet/Test | grep -q "Hello, Test!"
	@pkill -f "perl.*Server" 2>/dev/null || true
	@echo "E2E: PASS"

fatbin:
	@echo "Install PAR::Packer for fat binaries: cpan PAR::Packer"
	@echo "Then: pp -o server lib/Server.pm"

lint:
	perl -cw lib/*.pm

autoformat:
	perltidy -b lib/*.pm bin/*.pl 2>/dev/null; true

format-check:
	perltidy -st lib/*.pm 2>/dev/null | diff -q - lib/*.pm > /dev/null || echo "Needs formatting"
