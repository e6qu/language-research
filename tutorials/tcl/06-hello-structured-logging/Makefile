.PHONY: build clean test typecheck e2e fatbin lint autoformat format-check

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
	echo 'logger::info "Hello from fat bundle"' >> hello_bundle.tcl
	@echo "Fat bundle: hello_bundle.tcl (requires tclsh)"
	@ls -la hello_bundle.tcl

lint:
	nagelfar src/*.tcl 2>/dev/null || echo "Install nagelfar for linting"

autoformat:
	@echo "No standard Tcl formatter"

format-check:
	@echo "No standard Tcl formatter"
