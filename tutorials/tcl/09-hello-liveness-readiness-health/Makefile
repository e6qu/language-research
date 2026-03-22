.PHONY: build clean test typecheck e2e fatbin

build:
	@echo "No build step required for Tcl"

clean:
	@rm -f *.tmp

test:
	tclsh test/all.tcl

typecheck:
	@echo "No typecheck available for Tcl"

e2e:
	./run.sh

fatbin:
	cat src/*.tcl > hello_bundle.tcl
	echo '# Entry point' >> hello_bundle.tcl
	echo 'health_checker::init; puts [health_checker::status]' >> hello_bundle.tcl
	@echo "Fat bundle: hello_bundle.tcl (requires tclsh)"
	@ls -la hello_bundle.tcl
