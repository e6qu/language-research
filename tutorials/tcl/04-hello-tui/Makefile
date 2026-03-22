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
	@echo "TUI is interactive — verifying state logic via script"
	@echo 'source src/tui_state.tcl; set s [tui_state::new]; set s [tui_state::move_down $$s]; puts [tui_state::selected_item $$s]' | tclsh | grep -q "Lua"
	@echo "e2e passed"

fatbin:
	cat src/*.tcl > hello_bundle.tcl
	echo '# Entry point' >> hello_bundle.tcl
	echo 'tui::run' >> hello_bundle.tcl
	@echo "Fat bundle: hello_bundle.tcl (requires tclsh)"
	@ls -la hello_bundle.tcl
