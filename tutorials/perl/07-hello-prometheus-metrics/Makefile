.PHONY: build clean test typecheck e2e fatbin lint autoformat format-check

build:
	perl -c lib/Metrics.pm

clean:
	rm -f *.out

test:
	prove -v t/

typecheck:
	perl -c lib/Metrics.pm

e2e: build
	perl -Ilib -MMetrics -e 'my $$m = Metrics->new(); $$m->increment("up_total"); print $$m->format()' | grep -q "up_total"
	@echo "e2e passed"

fatbin:
	@echo "Install PAR::Packer for fat binaries: cpan PAR::Packer"
	@echo "Then: pp -o metrics lib/Metrics.pm"

lint:
	perl -cw lib/*.pm

autoformat:
	perltidy -b lib/*.pm bin/*.pl 2>/dev/null; true

format-check:
	perltidy -st lib/*.pm 2>/dev/null | diff -q - lib/*.pm > /dev/null || echo "Needs formatting"
