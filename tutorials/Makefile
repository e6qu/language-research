# tutorials/Makefile — orchestrates all child tutorial Makefiles
#
# Usage:
#   make test          — run all unit tests
#   make build         — build all tutorials
#   make e2e           — run E2E tests (exercises built binaries)
#   make typecheck     — type-check all tutorials
#   make clean         — clean all build artifacts
#   make binaries      — build release binaries and escripts
#   make docker-build  — build Docker tutorial environments
#
# Per-language: make {test,build,e2e,typecheck}-{lang}
#   Languages: elixir erlang elm lua tcl perl raku rust rust-wasm golang java java-springboot java-quarkus clojure

SHELL := /bin/bash

LANGUAGES := elixir erlang elm lua tcl perl raku rust rust-wasm golang java java-springboot java-quarkus clojure

ELIXIR_TUTORIALS     := $(sort $(wildcard elixir/[0-9]*/))
ERLANG_TUTORIALS     := $(sort $(wildcard erlang/[0-9]*/))
ELM_TUTORIALS        := $(sort $(wildcard elm/[0-9]*/))
LUA_TUTORIALS        := $(sort $(wildcard lua/[0-9]*/))
TCL_TUTORIALS        := $(sort $(wildcard tcl/[0-9]*/))
PERL_TUTORIALS       := $(sort $(wildcard perl/[0-9]*/))
RAKU_TUTORIALS       := $(sort $(wildcard raku/[0-9]*/))
RUST_TUTORIALS       := $(sort $(wildcard rust/[0-9]*/))
RUST_WASM_TUTORIALS  := $(sort $(wildcard rust-wasm/[0-9]*/))
GOLANG_TUTORIALS     := $(sort $(wildcard golang/[0-9]*/))
JAVA_TUTORIALS       := $(sort $(wildcard java/[0-9]*/))
SPRINGBOOT_TUTORIALS := $(sort $(wildcard java-springboot/[0-9]*/))
QUARKUS_TUTORIALS    := $(sort $(wildcard java-quarkus/[0-9]*/))
CLOJURE_TUTORIALS    := $(sort $(wildcard clojure/[0-9]*/))

ALL_TUTORIALS := $(ELIXIR_TUTORIALS) $(ERLANG_TUTORIALS) $(ELM_TUTORIALS) \
                 $(LUA_TUTORIALS) $(TCL_TUTORIALS) $(PERL_TUTORIALS) $(RAKU_TUTORIALS) \
                 $(RUST_TUTORIALS) $(RUST_WASM_TUTORIALS) $(GOLANG_TUTORIALS) \
                 $(JAVA_TUTORIALS) $(SPRINGBOOT_TUTORIALS) $(QUARKUS_TUTORIALS) \
                 $(CLOJURE_TUTORIALS)

TOTAL := $(words $(ALL_TUTORIALS))

# ─── Aggregate targets ────────────────────────────────────────

all: test build

TEST_TARGETS  := $(addprefix test-,$(LANGUAGES))
BUILD_TARGETS := $(addprefix build-,$(LANGUAGES))
E2E_TARGETS   := $(addprefix e2e-,$(LANGUAGES))
TC_TARGETS    := $(addprefix typecheck-,$(LANGUAGES))

test: $(TEST_TARGETS)
	@echo ""
	@echo "=== All $(TOTAL) tutorial tests passed ==="

build: $(BUILD_TARGETS)
	@echo ""
	@echo "=== All $(TOTAL) tutorials built ==="

typecheck: $(TC_TARGETS)
	@echo ""
	@echo "=== All type checks passed ==="

e2e: $(E2E_TARGETS)
	@echo ""
	@echo "=== All E2E tests passed ==="

clean:
	@for d in $(ALL_TUTORIALS); do \
		$(MAKE) -C $$d clean 2>/dev/null || true; \
	done
	@rm -rf _artifacts
	@echo "Done."

# ─── Per-language targets (delegate to child Makefiles) ───────

define run_target # $(1)=tutorials_list, $(2)=make_target, $(3)=label
	@failures=0; \
	for d in $(1); do \
		name=$$(basename $$d); \
		printf "  %-45s" "$$name"; \
		if $(MAKE) -C $$d $(2) > /tmp/make-$$name.log 2>&1; then \
			echo "OK"; \
		else \
			echo "FAIL"; \
			tail -20 /tmp/make-$$name.log; \
			failures=$$((failures + 1)); \
		fi; \
	done; \
	if [ $$failures -gt 0 ]; then echo "$$failures $(3) tutorial(s) failed"; exit 1; fi
endef

test-elixir:
	@echo "=== Testing Elixir tutorials ==="
	$(call run_target,$(ELIXIR_TUTORIALS),test,Elixir)

test-erlang:
	@echo "=== Testing Erlang tutorials ==="
	$(call run_target,$(ERLANG_TUTORIALS),test,Erlang)

test-elm:
	@echo "=== Testing Elm tutorials ==="
	$(call run_target,$(ELM_TUTORIALS),test,Elm)

test-lua:
	@echo "=== Testing Lua tutorials ==="
	$(call run_target,$(LUA_TUTORIALS),test,Lua)

test-tcl:
	@echo "=== Testing Tcl tutorials ==="
	$(call run_target,$(TCL_TUTORIALS),test,Tcl)

test-perl:
	@echo "=== Testing Perl tutorials ==="
	$(call run_target,$(PERL_TUTORIALS),test,Perl)

test-raku:
	@echo "=== Testing Raku tutorials ==="
	$(call run_target,$(RAKU_TUTORIALS),test,Raku)

test-rust:
	@echo "=== Testing Rust tutorials ==="
	$(call run_target,$(RUST_TUTORIALS),test,Rust)

test-rust-wasm:
	@echo "=== Testing Rust-WASM tutorials ==="
	$(call run_target,$(RUST_WASM_TUTORIALS),test,Rust-WASM)

test-golang:
	@echo "=== Testing Go tutorials ==="
	$(call run_target,$(GOLANG_TUTORIALS),test,Go)

test-java:
	@echo "=== Testing Java tutorials ==="
	$(call run_target,$(JAVA_TUTORIALS),test,Java)

test-java-springboot:
	@echo "=== Testing Spring Boot tutorials ==="
	$(call run_target,$(SPRINGBOOT_TUTORIALS),test,SpringBoot)

test-java-quarkus:
	@echo "=== Testing Quarkus tutorials ==="
	$(call run_target,$(QUARKUS_TUTORIALS),test,Quarkus)

test-clojure:
	@echo "=== Testing Clojure tutorials ==="
	$(call run_target,$(CLOJURE_TUTORIALS),test,Clojure)

build-elixir:
	@echo "=== Building Elixir tutorials ==="
	$(call run_target,$(ELIXIR_TUTORIALS),build,Elixir)

build-erlang:
	@echo "=== Building Erlang tutorials ==="
	$(call run_target,$(ERLANG_TUTORIALS),build,Erlang)

build-elm:
	@echo "=== Building Elm tutorials ==="
	$(call run_target,$(ELM_TUTORIALS),build,Elm)

build-lua:
	@echo "=== Building Lua tutorials ==="
	$(call run_target,$(LUA_TUTORIALS),build,Lua)

build-tcl:
	@echo "=== Building Tcl tutorials ==="
	$(call run_target,$(TCL_TUTORIALS),build,Tcl)

build-perl:
	@echo "=== Building Perl tutorials ==="
	$(call run_target,$(PERL_TUTORIALS),build,Perl)

build-raku:
	@echo "=== Building Raku tutorials ==="
	$(call run_target,$(RAKU_TUTORIALS),build,Raku)

build-rust:
	@echo "=== Building Rust tutorials ==="
	$(call run_target,$(RUST_TUTORIALS),build,Rust)

build-rust-wasm:
	@echo "=== Building Rust-WASM tutorials ==="
	$(call run_target,$(RUST_WASM_TUTORIALS),build,Rust-WASM)

build-golang:
	@echo "=== Building Go tutorials ==="
	$(call run_target,$(GOLANG_TUTORIALS),build,Go)

build-java:
	@echo "=== Building Java tutorials ==="
	$(call run_target,$(JAVA_TUTORIALS),build,Java)

build-java-springboot:
	@echo "=== Building Spring Boot tutorials ==="
	$(call run_target,$(SPRINGBOOT_TUTORIALS),build,SpringBoot)

build-java-quarkus:
	@echo "=== Building Quarkus tutorials ==="
	$(call run_target,$(QUARKUS_TUTORIALS),build,Quarkus)

build-clojure:
	@echo "=== Building Clojure tutorials ==="
	$(call run_target,$(CLOJURE_TUTORIALS),build,Clojure)

e2e-elixir:
	@echo "=== E2E Elixir tutorials ==="
	$(call run_target,$(ELIXIR_TUTORIALS),e2e,Elixir)

e2e-erlang:
	@echo "=== E2E Erlang tutorials ==="
	$(call run_target,$(ERLANG_TUTORIALS),e2e,Erlang)

e2e-elm:
	@echo "=== E2E Elm tutorials ==="
	$(call run_target,$(ELM_TUTORIALS),e2e,Elm)

e2e-lua:
	@echo "=== E2E Lua tutorials ==="
	$(call run_target,$(LUA_TUTORIALS),e2e,Lua)

e2e-tcl:
	@echo "=== E2E Tcl tutorials ==="
	$(call run_target,$(TCL_TUTORIALS),e2e,Tcl)

e2e-perl:
	@echo "=== E2E Perl tutorials ==="
	$(call run_target,$(PERL_TUTORIALS),e2e,Perl)

e2e-raku:
	@echo "=== E2E Raku tutorials ==="
	$(call run_target,$(RAKU_TUTORIALS),e2e,Raku)

e2e-rust:
	@echo "=== E2E Rust tutorials ==="
	$(call run_target,$(RUST_TUTORIALS),e2e,Rust)

e2e-rust-wasm:
	@echo "=== E2E Rust-WASM tutorials ==="
	$(call run_target,$(RUST_WASM_TUTORIALS),e2e,Rust-WASM)

e2e-golang:
	@echo "=== E2E Go tutorials ==="
	$(call run_target,$(GOLANG_TUTORIALS),e2e,Go)

e2e-java:
	@echo "=== E2E Java tutorials ==="
	$(call run_target,$(JAVA_TUTORIALS),e2e,Java)

e2e-java-springboot:
	@echo "=== E2E Spring Boot tutorials ==="
	$(call run_target,$(SPRINGBOOT_TUTORIALS),e2e,SpringBoot)

e2e-java-quarkus:
	@echo "=== E2E Quarkus tutorials ==="
	$(call run_target,$(QUARKUS_TUTORIALS),e2e,Quarkus)

e2e-clojure:
	@echo "=== E2E Clojure tutorials ==="
	$(call run_target,$(CLOJURE_TUTORIALS),e2e,Clojure)

typecheck-elixir:
	@echo "=== Type-checking Elixir tutorials ==="
	$(call run_target,$(ELIXIR_TUTORIALS),typecheck,Elixir)

typecheck-erlang:
	@echo "=== Type-checking Erlang tutorials ==="
	$(call run_target,$(ERLANG_TUTORIALS),typecheck,Erlang)

typecheck-elm:
	@echo "=== Type-checking Elm tutorials ==="
	$(call run_target,$(ELM_TUTORIALS),typecheck,Elm)

typecheck-lua:
	@echo "=== Type-checking Lua tutorials ==="
	$(call run_target,$(LUA_TUTORIALS),typecheck,Lua)

typecheck-tcl:
	@echo "=== Type-checking Tcl tutorials ==="
	$(call run_target,$(TCL_TUTORIALS),typecheck,Tcl)

typecheck-perl:
	@echo "=== Type-checking Perl tutorials ==="
	$(call run_target,$(PERL_TUTORIALS),typecheck,Perl)

typecheck-raku:
	@echo "=== Type-checking Raku tutorials ==="
	$(call run_target,$(RAKU_TUTORIALS),typecheck,Raku)

typecheck-rust:
	@echo "=== Type-checking Rust tutorials ==="
	$(call run_target,$(RUST_TUTORIALS),typecheck,Rust)

typecheck-rust-wasm:
	@echo "=== Type-checking Rust-WASM tutorials ==="
	$(call run_target,$(RUST_WASM_TUTORIALS),typecheck,Rust-WASM)

typecheck-golang:
	@echo "=== Type-checking Go tutorials ==="
	$(call run_target,$(GOLANG_TUTORIALS),typecheck,Go)

typecheck-java:
	@echo "=== Type-checking Java tutorials ==="
	$(call run_target,$(JAVA_TUTORIALS),typecheck,Java)

typecheck-java-springboot:
	@echo "=== Type-checking Spring Boot tutorials ==="
	$(call run_target,$(SPRINGBOOT_TUTORIALS),typecheck,SpringBoot)

typecheck-java-quarkus:
	@echo "=== Type-checking Quarkus tutorials ==="
	$(call run_target,$(QUARKUS_TUTORIALS),typecheck,Quarkus)

typecheck-clojure:
	@echo "=== Type-checking Clojure tutorials ==="
	$(call run_target,$(CLOJURE_TUTORIALS),typecheck,Clojure)

# ─── Binary artifact targets ──────────────────────────────────

_artifacts:
	@mkdir -p _artifacts

binaries: _artifacts binaries-elixir binaries-erlang binaries-elm
	@echo ""
	@echo "=== Artifact summary ==="
	@ls -lhS _artifacts/ 2>/dev/null
	@echo ""
	@echo "=== All binaries built ==="

binaries-elixir: _artifacts
	@echo "=== Building Elixir binaries ==="
	@echo "  escript (03-hello-cli)..."
	@$(MAKE) -C elixir/03-hello-cli escript 2>/dev/null
	@cp elixir/03-hello-cli/hello_cli _artifacts/elixir-hello-cli.escript
	@echo "    -> $$(du -h _artifacts/elixir-hello-cli.escript | cut -f1)"
	@echo "  mix release (03-hello-cli)..."
	@cd elixir/03-hello-cli && MIX_ENV=prod mix release --overwrite --quiet 2>/dev/null
	@echo "    -> $$(du -sh elixir/03-hello-cli/_build/prod/rel/hello_cli/ | cut -f1)"
	@echo "  mix release (02-hello-web-server)..."
	@cd elixir/02-hello-web-server && MIX_ENV=prod mix release --overwrite --quiet 2>/dev/null
	@echo "    -> $$(du -sh elixir/02-hello-web-server/_build/prod/rel/hello_web/ | cut -f1)"

binaries-erlang: _artifacts
	@echo "=== Building Erlang binaries ==="
	@echo "  escript (03-hello-cli)..."
	@$(MAKE) -C erlang/03-hello-cli escript 2>/dev/null
	@cp erlang/03-hello-cli/_build/default/bin/hello_cli _artifacts/erlang-hello-cli.escript
	@echo "    -> $$(du -h _artifacts/erlang-hello-cli.escript | cut -f1)"
	@echo "  rebar3 release (01-hello-world)..."
	@cd erlang/01-hello-world && rebar3 release 2>/dev/null
	@echo "    -> $$(du -sh erlang/01-hello-world/_build/default/rel/hello/ | cut -f1)"
	@echo "  rebar3 release (02-hello-web-server)..."
	@cd erlang/02-hello-web-server && rebar3 release 2>/dev/null
	@echo "    -> $$(du -sh erlang/02-hello-web-server/_build/default/rel/hello_web/ | cut -f1)"

binaries-elm: _artifacts
	@echo "=== Building Elm optimized JS ==="
	@for d in $(ELM_TUTORIALS); do \
		name=$$(basename $$d); \
		printf "  %-45s" "$$name"; \
		if $(MAKE) -C $$d build > /dev/null 2>&1; then \
			js=$$(find $$d -maxdepth 1 -name '*.js' -not -name 'elm-stuff' | head -1); \
			if [ -n "$$js" ]; then \
				size=$$(wc -c < "$$js" | tr -d ' '); \
				cp "$$js" _artifacts/elm-$$name.js; \
				echo "$$(( size / 1024 )) KB"; \
			else \
				echo "OK (no JS output)"; \
			fi; \
		else \
			echo "SKIP"; \
		fi; \
	done

# ─── Docker targets ───────────────────────────────────────────

DOCKER_TARGETS := $(addprefix docker-,$(LANGUAGES))

docker-build: $(DOCKER_TARGETS)
	@echo ""
	@echo "=== All Docker images built ==="

docker-elixir:
	@echo "=== Building Elixir Docker image ==="
	docker build -f elixir/Dockerfile.tutorial-env -t tutorial-elixir elixir/

docker-erlang:
	@echo "=== Building Erlang Docker image ==="
	docker build -f erlang/Dockerfile.tutorial-env -t tutorial-erlang erlang/

docker-elm:
	@echo "=== Building Elm Docker image ==="
	docker build -f elm/Dockerfile.tutorial-env -t tutorial-elm elm/

docker-lua:
	@echo "=== Building Lua Docker image ==="
	docker build -f lua/Dockerfile.tutorial-env -t tutorial-lua lua/

docker-tcl:
	@echo "=== Building Tcl Docker image ==="
	docker build -f tcl/Dockerfile.tutorial-env -t tutorial-tcl tcl/

docker-perl:
	@echo "=== Building Perl Docker image ==="
	docker build -f perl/Dockerfile.tutorial-env -t tutorial-perl perl/

docker-raku:
	@echo "=== Building Raku Docker image ==="
	docker build -f raku/Dockerfile.tutorial-env -t tutorial-raku raku/

docker-rust:
	@echo "=== Building Rust Docker image ==="
	docker build -f rust/Dockerfile.tutorial-env -t tutorial-rust rust/

docker-rust-wasm:
	@echo "=== Building Rust-WASM Docker image ==="
	docker build -f rust-wasm/Dockerfile.tutorial-env -t tutorial-rust-wasm rust-wasm/

docker-golang:
	@echo "=== Building Go Docker image ==="
	docker build -f golang/Dockerfile.tutorial-env -t tutorial-golang golang/

docker-java:
	@echo "=== Building Java Docker image ==="
	docker build -f java/Dockerfile.tutorial-env -t tutorial-java java/

docker-java-springboot:
	@echo "=== Building Spring Boot Docker image ==="
	docker build -f java-springboot/Dockerfile.tutorial-env -t tutorial-springboot java-springboot/

docker-java-quarkus:
	@echo "=== Building Quarkus Docker image ==="
	docker build -f java-quarkus/Dockerfile.tutorial-env -t tutorial-quarkus java-quarkus/

docker-clojure:
	@echo "=== Building Clojure Docker image ==="
	docker build -f clojure/Dockerfile.tutorial-env -t tutorial-clojure clojure/
