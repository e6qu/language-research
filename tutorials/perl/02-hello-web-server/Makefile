.PHONY: build clean test typecheck e2e fatbin

build:
	perl -c lib/Server.pm

clean:
	rm -f *.out

test:
	prove -v t/

typecheck:
	perl -c lib/Server.pm

e2e: build
	perl -Ilib -MServer -e 'Server::start(9876)' &
	sleep 1
	curl -s http://localhost:9876/ | grep -q "Hello, world!"
	curl -s http://localhost:9876/greet/E2E | grep -q "Hello, E2E!"
	kill %1 2>/dev/null || true
	@echo "e2e passed"

fatbin:
	@echo "Install PAR::Packer for fat binaries: cpan PAR::Packer"
	@echo "Then: pp -o server lib/Server.pm"
