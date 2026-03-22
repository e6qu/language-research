.PHONY: build clean test typecheck e2e fatbin lint autoformat format-check

build:
	perl -c lib/ParallelFetch.pm

clean:
	rm -f *.out

test:
	prove -v t/

typecheck:
	perl -c lib/ParallelFetch.pm

e2e: build
	perl -Ilib -MParallelFetch -e 'print scalar(ParallelFetch::fetch_all("a","b")), "\n"' | grep -q "2"
	@echo "e2e passed"

fatbin:
	@echo "Install PAR::Packer for fat binaries: cpan PAR::Packer"
	@echo "Then: pp -o parallel_fetch lib/ParallelFetch.pm"

lint:
	perl -cw lib/*.pm

autoformat:
	perltidy -b lib/*.pm bin/*.pl 2>/dev/null; true

format-check:
	perltidy -st lib/*.pm 2>/dev/null | diff -q - lib/*.pm > /dev/null || echo "Needs formatting"
