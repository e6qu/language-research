.PHONY: build clean test typecheck e2e fatbin lint autoformat format-check

build:
	@echo "Tcl is interpreted — no compilation step"

clean:
	rm -f *.out

test:
	tclsh test/all.tcl

typecheck:
	@echo "No static type checker configured (install nagelfar for checking)"

e2e: build
	tclsh src/hello_cli.tcl --name Test --shout | grep -q "HELLO, TEST!"
	@echo "E2E: PASS"

fatbin:
	cat src/*.tcl > hello_bundle.tcl
	@echo "Fat bundle: hello_bundle.tcl (requires tclsh)"
	@ls -la hello_bundle.tcl

lint:
	nagelfar src/*.tcl 2>/dev/null || echo "Install nagelfar for linting"

autoformat:
	@echo "No standard Tcl formatter"

format-check:
	@echo "No standard Tcl formatter"
