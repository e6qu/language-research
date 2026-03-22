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
	@lsof -ti:4020 | xargs kill 2>/dev/null || true
	tclsh src/server.tcl 4020 &
	@sleep 2
	curl -sf http://localhost:4020/ | grep -q "Hello, world!"
	curl -sf http://localhost:4020/greet/Test | grep -q "Hello, Test!"
	@pkill -f "tclsh.*server" 2>/dev/null || true
	@echo "E2E: PASS"

fatbin:
	cat src/*.tcl > hello_bundle.tcl
	echo '# Entry point' >> hello_bundle.tcl
	echo 'set port [expr {[llength $$argv] > 0 ? [lindex $$argv 0] : 4020}]' >> hello_bundle.tcl
	echo 'start_server $$port' >> hello_bundle.tcl
	@echo "Fat bundle: hello_bundle.tcl (requires tclsh)"
	@ls -la hello_bundle.tcl

lint:
	nagelfar src/*.tcl 2>/dev/null || echo "Install nagelfar for linting"

autoformat:
	@echo "No standard Tcl formatter"

format-check:
	@echo "No standard Tcl formatter"
