.PHONY: build clean test typecheck e2e fatbin lint autoformat format-check

build:
	perl -c lib/HealthChecker.pm

clean:
	rm -f *.out

test:
	prove -v t/

typecheck:
	perl -c lib/HealthChecker.pm

e2e: build
	perl -Ilib -MHealthChecker -e 'my $$h = HealthChecker->new(); print $$h->liveness_json(), "\n"' | grep -q "ok"
	@echo "e2e passed"

fatbin:
	@echo "Install PAR::Packer for fat binaries: cpan PAR::Packer"
	@echo "Then: pp -o health lib/HealthChecker.pm"

lint:
	perl -cw lib/*.pm

autoformat:
	perltidy -b lib/*.pm bin/*.pl 2>/dev/null; true

format-check:
	perltidy -st lib/*.pm 2>/dev/null | diff -q - lib/*.pm > /dev/null || echo "Needs formatting"
