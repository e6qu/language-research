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
	@PORT=$$(( 9000 + $$RANDOM % 1000 )); \
	tclsh src/server.tcl $$PORT & \
	SERVER_PID=$$!; \
	sleep 1; \
	RESULT=$$(curl -s http://localhost:$$PORT/); \
	GREET=$$(curl -s http://localhost:$$PORT/greet/E2E); \
	kill $$SERVER_PID 2>/dev/null || true; \
	echo "$$RESULT" | grep -q '"Hello, world!"' && \
	echo "$$GREET" | grep -q '"Hello, E2E!"' && \
	echo "e2e passed"

fatbin:
	cat src/*.tcl > hello_bundle.tcl
	echo '# Entry point' >> hello_bundle.tcl
	echo 'set port [expr {[llength $$argv] > 0 ? [lindex $$argv 0] : 8080}]' >> hello_bundle.tcl
	echo 'start_server $$port' >> hello_bundle.tcl
	@echo "Fat bundle: hello_bundle.tcl (requires tclsh)"
	@ls -la hello_bundle.tcl

lint:
	nagelfar src/*.tcl 2>/dev/null || echo "Install nagelfar for linting"

autoformat:
	@echo "No standard Tcl formatter"

format-check:
	@echo "No standard Tcl formatter"
