# language-research

A multi-language comparison project exploring the suitability of 14 languages and frameworks for building AI agents, CLIs, web servers, TUIs, and web GUIs.

**126 tutorials** (14 tracks × 9 topics), each with source code, unit tests, E2E tests, and a uniform Makefile. **15 summary documents** comparing type systems, error handling, concurrency models, protocol support, binary distribution, and notable production software.

## Languages

| Track | Type System | Concurrency | Fat Binary | Test Framework |
|---|---|---|---|---|
| **Elixir** | Dynamic (gradual typing WIP) | Preemptive processes (BEAM) | mix release / Burrito | ExUnit |
| **Erlang** | Dynamic (Dialyzer) | Preemptive processes (BEAM) | rebar3 release / warp-packer | EUnit |
| **Elm** | Static (Hindley-Milner) | Cmd.batch (managed effects) | elm make → JS / Tauri | elm-test |
| **Lua** | Dynamic (Teal optional) | Coroutines (cooperative) | luastatic (~244 KB!) | busted |
| **Tcl** | Dynamic (everything-is-a-string) | Event loop + threads | Starpacks (~2-10 MB) | tcltest |
| **Perl** | Dynamic | fork / IO::Async | PAR::Packer | Test::More / prove |
| **Raku** | Gradual (best among dynamic) | Promises / channels / hyper | — | built-in Test |
| **Rust** | Static (ownership + lifetimes) | async/await (tokio) | Static binary (~2-5 MB musl) | cargo test |
| **Rust-WASM** | Static | wasm-bindgen-futures | .wasm module | cargo test |
| **Go** | Static (structural interfaces) | Goroutines + channels | Static binary by default! | go test |
| **Java** | Static (nominal) | Virtual threads (21+) | Fat JAR / jlink / native-image | JUnit 5 |
| **Spring Boot** | Static | @Async / WebFlux | Fat JAR / Spring Native | Spring Boot Test |
| **Quarkus** | Static | Mutiny reactive / virtual threads | Native binary (GraalVM AoT) | @QuarkusTest |
| **Clojure** | Dynamic (spec, Malli) | Atoms / refs (STM) / core.async | lein uberjar / GraalVM | clojure.test |

## Tutorials

Each track covers the same 9 topics:

| # | Topic | What it builds |
|---|---|---|
| 01 | Hello World | Project setup, module, unit tests |
| 02 | Web Server | JSON HTTP API with routing |
| 03 | CLI | Command-line tool with flags |
| 04 | TUI | Terminal UI with keyboard navigation |
| 05 | Concurrency | Parallel execution patterns |
| 06 | Structured Logging | JSON log output |
| 07 | Prometheus Metrics | /metrics endpoint |
| 08 | OpenAPI Schema | Spec generation / validation |
| 09 | Health Checks | /healthz, /readyz, /health |

## Quick Start

```bash
cd tutorials

# Run all 117 tests
make test

# Run tests for one language
make test-elixir
make test-rust
make test-golang

# Run a single tutorial
cd rust/01-hello-world && make test

# Build all tutorials
make build

# Run E2E tests (exercises built binaries)
make e2e

# Build fat binaries / release artifacts
make fatbin    # per-tutorial
make binaries  # aggregated artifacts in _artifacts/

# Type-check everything
make typecheck

# Clean all build artifacts
make clean
```

## Per-Tutorial Makefile

Every tutorial has a Makefile with uniform targets:

```bash
make build      # compile
make test       # unit tests
make e2e        # integration tests against built artifact
make typecheck  # static analysis (cargo check, go vet, Dialyzer, elm make, etc.)
make fatbin     # produce release binary / fat JAR / optimized JS / native exe
make clean      # remove build artifacts
```

## Summary Documents

In-depth comparison docs at the project root:

| Document | Covers |
|---|---|
| [BEAM.md](BEAM.md) | VM architecture, fault tolerance, scheduling, IPC, cgroups |
| [ELIXIR.md](ELIXIR.md) | Elixir language, Phoenix, LiveView, Nx/Bumblebee for ML |
| [ERLANG.md](ERLANG.md) | Erlang/OTP, Cowboy, bit syntax, Dialyzer |
| [ELM.md](ELM.md) | Type system, TEA, no-runtime-exceptions, ports |
| [LUA.md](LUA.md) | Embeddability, LuaJIT, metatables, Luerl on BEAM |
| [TCL.md](TCL.md) | Tk GUI, Expect, starpacks, introspection |
| [PERL.md](PERL.md) | CPAN, Mojolicious, regexes, PAR::Packer |
| [RAKU.md](RAKU.md) | Grammars, gradual types, MAIN signatures, junctions |
| [RUST.md](RUST.md) | Ownership, async/await, axum, ratatui, zero-cost abstractions |
| [RUST_WASM.md](RUST_WASM.md) | wasm-pack, wasm-bindgen, web-sys, vs Elm comparison |
| [GO.md](GO.md) | Goroutines, channels, net/http, slog, static binaries |
| [JAVA.md](JAVA.md) | Virtual threads, records, sealed classes, JVM internals |
| [JAVA_SPRINGBOOT.md](JAVA_SPRINGBOOT.md) | Auto-config, actuator, micrometer, Spring Native |
| [JAVA_QUARKUS.md](JAVA_QUARKUS.md) | Build-time DI, GraalVM native, MicroProfile, Dev Services |
| [CLOJURE.md](CLOJURE.md) | Persistent data, STM, core.async, spec, REPL-driven dev |

## Development Environments

### Nix Flakes (reproducible)

Each language directory has a `flake.nix`:

```bash
cd tutorials/elixir && nix develop    # Elixir 1.17 + OTP 27
cd tutorials/rust   && nix develop    # Rust stable + cargo
cd tutorials/golang && nix develop    # Go 1.23+
```

### Docker

Each language has a `Dockerfile.tutorial-env`:

```bash
cd tutorials
make docker-build                    # build all 13 images
docker run --rm -v $(pwd)/rust:/tutorials -w /tutorials/01-hello-world tutorial-rust make test
```

### Homebrew (macOS)

```bash
brew install elixir erlang rebar3 elm lua luarocks tcl-tk rakudo
npm install -g elm-test
# Rust, Go, Java installed separately
```

## File Structure

```
language-research/
├── README.md                           # this file
├── BEAM.md ... JAVA_QUARKUS.md        # 14 summary docs
└── tutorials/
    ├── Makefile                        # orchestrates all 117 tutorials
    ├── README.md                       # detailed test instructions
    ├── elixir/                         # 9 tutorials + flake.nix + Dockerfile
    ├── erlang/
    ├── elm/
    ├── lua/
    ├── tcl/
    ├── perl/
    ├── raku/
    ├── rust/
    ├── rust-wasm/
    ├── golang/
    ├── java/
    ├── java-springboot/
    ├── java-quarkus/
    └── clojure/
```

## Binary Size Comparison

From `make fatbin` on tutorial 01 (hello-world):

| Language | Binary Type | Size |
|---|---|---|
| **Lua** (luastatic) | Native static binary | 244 KB |
| **Go** | Native static binary | ~2 MB |
| **Rust** | Native static binary | ~1-4 MB |
| **Rust-WASM** | .wasm module | ~30-100 KB |
| **Elm** | Optimized JS | ~106 KB |
| **Tcl** (starpack) | Script bundle | ~200 B (needs tclsh) |
| **Perl** | Script | needs perl |
| **Raku** | Script | needs raku |
| **Elixir** (mix release) | BEAM release + ERTS | ~15 MB |
| **Erlang** (rebar3 release) | BEAM release + ERTS | ~25 MB |
| **Java** (fat JAR) | JAR + JVM classes | ~5-15 MB |
| **Spring Boot** (fat JAR) | JAR + framework + JVM | ~20-40 MB |
| **Quarkus** (native) | GraalVM native binary | ~20-50 MB |

## License

This project is for educational and research purposes.
