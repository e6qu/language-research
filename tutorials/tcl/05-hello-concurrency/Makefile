.PHONY: build clean test typecheck e2e fatbin

build:
	@echo "Tcl is interpreted — no compilation step"

clean:
	rm -f *.out

test:
	tclsh test/all.tcl

typecheck:
	@echo "No static type checker configured (install nagelfar for checking)"

e2e: build
	@echo 'source src/concurrent.tcl; set r [concurrent::fetch_all {http://a.com http://b.com}]; puts "count=[llength $$r]"; puts "url=[dict get [lindex $$r 0] url]"' | tclsh | grep -q "count=2"
	@echo "e2e passed"

fatbin:
	cat src/*.tcl > hello_bundle.tcl
	echo '# Entry point' >> hello_bundle.tcl
	echo 'puts [concurrent::fetch_all [list]]' >> hello_bundle.tcl
	@echo "Fat bundle: hello_bundle.tcl (requires tclsh)"
	@ls -la hello_bundle.tcl
