# BEAM & Elm Tutorials

27 self-contained tutorials covering Elixir, Erlang, and Elm — each with source code, unit tests, E2E tests, build scripts, and a Makefile.

## Prerequisites

You need ONE of the following environments:

### Option A: Local install (Homebrew on macOS)

```bash
brew install elixir erlang rebar3 elm
npm install -g elm-test
mix local.hex --force
mix local.rebar --force
```

Verify:

```bash
elixir --version    # >= 1.17
erl -noshell -eval 'io:format("OTP ~s~n", [erlang:system_info(otp_release)]), halt().'  # >= 27
rebar3 version      # >= 3.24
elm --version       # 0.19.1
elm-test --version  # >= 0.19.1
```

### Option B: Nix flakes (reproducible, per-language)

```bash
# Enable flakes if not already configured
echo 'experimental-features = nix-command flakes' >> ~/.config/nix/nix.conf

# Enter a dev shell for one language
cd tutorials/elixir && nix develop   # Elixir 1.17 + OTP 27 + rebar3
cd tutorials/erlang && nix develop   # OTP 27 + rebar3
cd tutorials/elm    && nix develop   # Elm 0.19.1 + Node 20 + elm-test

# Run a single command inside the shell
cd tutorials/elixir && nix develop --command bash -c 'cd 01-hello-world && make test'
```

If switching between Nix and Homebrew toolchains, run `make clean` first
(the `_build` directories are OTP-version-specific).

### Option C: Docker (no local install needed)

```bash
# Build images (supports linux/arm64 and linux/amd64)
cd tutorials
make docker-build

# Or build individually
docker build -f elixir/Dockerfile.tutorial-env -t tutorial-elixir elixir/
docker build -f erlang/Dockerfile.tutorial-env -t tutorial-erlang erlang/
docker build -f elm/Dockerfile.tutorial-env    -t tutorial-elm    elm/

# Interactive shell
docker run -it --rm -v "$(pwd)/elixir":/tutorials -w /tutorials tutorial-elixir bash

# Run a specific tutorial's tests
docker run --rm -v "$(pwd)/elixir":/tutorials -w /tutorials/01-hello-world tutorial-elixir make test
```

## Running Tests

All commands are run from the `tutorials/` directory.

### Run all 27 unit tests

```bash
make test
```

Output:
```
=== Testing Elixir tutorials ===
  01-hello-world                               OK
  02-hello-web-server                          OK
  ...
=== Testing Erlang tutorials ===
  01-hello-world                               OK
  ...
=== Testing Elm tutorials ===
  01-hello-world                               OK
  ...

=== All 27 tutorial tests passed ===
```

### Run tests for one language

```bash
make test-elixir
make test-erlang
make test-elm
```

### Run tests for a single tutorial

```bash
cd elixir/01-hello-world && make test
cd erlang/03-hello-cli   && make test
cd elm/04-hello-tui      && make test
```

### Run E2E tests (exercises built binaries)

E2E tests build the artifact (escript, release, or optimized JS), then verify
it works by running it and checking the output:

```bash
make e2e           # all 27
make e2e-elixir    # Elixir only
make e2e-erlang    # Erlang only
make e2e-elm       # Elm only

# Single tutorial
cd elixir/03-hello-cli && make e2e
```

What E2E tests do per tutorial type:

| Type | What E2E does |
|---|---|
| **Elixir web** (02,07,08,09) | Build mix release → start daemon → curl endpoints → stop daemon |
| **Elixir CLI** (03) | Build escript → run with flags → grep output |
| **Elixir logic** (01,05,06) | Build → run via `mix run -e` or release eval → check output |
| **Erlang web** (02) | Build → start `erl -pa` background → curl → pkill |
| **Erlang CLI** (03) | Build escript → run with flags → grep output |
| **Erlang logic** (01,05-09) | Build → run via `erl -pa -noshell -eval` → check output |
| **Elm** (all) | Build optimized JS → `node -c` syntax check → verify non-empty |
| **TUI** (04 in all) | Build only (interactive apps can't be E2E tested) |

### Build all tutorials

```bash
make build           # compile all 27
make build-elixir    # Elixir only
make build-erlang    # Erlang only
make build-elm       # Elm only
```

### Type-check all tutorials

```bash
make typecheck           # all 27
make typecheck-elixir    # Dialyzer
make typecheck-erlang    # Dialyzer
make typecheck-elm       # Elm compiler (compilation IS type-checking)
```

Note: Dialyzer's first run builds a PLT (Persistent Lookup Table) which takes
several minutes. Subsequent runs are fast.

### Build release binaries

```bash
make binaries
```

Produces artifacts in `_artifacts/`:

| Artifact | Type | Size |
|---|---|---|
| `elixir-hello-cli.escript` | Elixir escript (needs Erlang on target) | ~1.4 MB |
| `erlang-hello-cli.escript` | Erlang escript (needs Erlang on target) | ~4 KB |
| `elm-*.js` | Optimized JavaScript | 100-146 KB |

Also builds in-place:

| Location | Type | Size |
|---|---|---|
| `elixir/03-hello-cli/_build/prod/rel/hello_cli/` | Mix release (self-contained with ERTS) | ~15 MB |
| `elixir/02-hello-web-server/_build/prod/rel/hello_web/` | Mix release (self-contained with ERTS) | ~20 MB |
| `erlang/01-hello-world/_build/default/rel/hello/` | Rebar3 release (self-contained with ERTS) | ~25 MB |
| `erlang/02-hello-web-server/_build/default/rel/hello_web/` | Rebar3 release (self-contained with ERTS) | ~42 MB |

### Clean everything

```bash
make clean
```

## Per-Tutorial Makefile

Every tutorial has a Makefile with these uniform targets:

```bash
cd elixir/01-hello-world   # or any tutorial

make build      # compile the project
make test       # run unit tests
make e2e        # run E2E tests (builds first)
make typecheck  # run type checker
make clean      # remove build artifacts
```

Some tutorials have additional targets:

```bash
# Elixir/Erlang CLI tutorials
make escript    # build a standalone escript

# Elixir/Erlang web tutorials
make release    # build an OTP release with bundled ERTS
```

## Tutorial Matrix

| # | Topic | Elixir | Erlang | Elm |
|---|-------|--------|--------|-----|
| 01 | Hello World | Mix + ExUnit | Rebar3 + EUnit | elm-test |
| 02 | Web Server | Plug + Bandit | Cowboy + jsx | HTTP client (Browser.element) |
| 03 | CLI | OptionParser + escript | argparse + escript | Command palette (browser) |
| 04 | TUI | Owl | ANSI escape codes | Terminal grid (browser) |
| 05 | Concurrency | Task.async_stream | spawn + message passing | Cmd.batch |
| 06 | Structured Logging | LoggerJSON | Custom JSON formatter | Ports to console.log |
| 07 | Prometheus Metrics | TelemetryMetricsPrometheus | prometheus.erl | Metrics dashboard |
| 08 | OpenAPI Schema | open_api_spex | Manual spec + jsx | Type-safe API client |
| 09 | Health Checks | Plug routes | Cowboy handlers | Health dashboard |

## File Structure

```
tutorials/
├── Makefile                          # orchestrates child Makefiles
├── README.md                         # this file
├── _artifacts/                       # built by `make binaries`
├── elixir/
│   ├── flake.nix                     # Nix dev environment
│   ├── Dockerfile.tutorial-env       # Docker dev environment
│   ├── 01-hello-world/
│   │   ├── Makefile                  # build/test/e2e/clean/typecheck
│   │   ├── README.md                 # tutorial walkthrough
│   │   ├── run.sh                    # standalone test+demo script
│   │   ├── mix.exs                   # project config
│   │   ├── mix.lock                  # dependency lockfile
│   │   ├── lib/                      # source code
│   │   └── test/                     # unit tests
│   ├── 02-hello-web-server/
│   │   └── ...
│   └── ... (09 total)
├── erlang/
│   ├── flake.nix
│   ├── Dockerfile.tutorial-env
│   ├── 01-hello-world/
│   │   ├── Makefile
│   │   ├── README.md
│   │   ├── run.sh
│   │   ├── rebar.config
│   │   ├── rebar.lock                # dependency lockfile
│   │   ├── src/                      # source code
│   │   └── test/                     # unit tests
│   └── ... (09 total)
└── elm/
    ├── flake.nix
    ├── Dockerfile.tutorial-env
    ├── 01-hello-world/
    │   ├── Makefile
    │   ├── README.md
    │   ├── run.sh
    │   ├── elm.json                  # project config + pinned deps (acts as lockfile)
    │   ├── src/                      # source code
    │   ├── tests/                    # unit tests
    │   └── index.html                # browser host page
    └── ... (09 total)
```

## Lockfiles

- **Elixir**: `mix.lock` — auto-generated by `mix deps.get`. Pinned in each tutorial with deps.
- **Erlang**: `rebar.lock` — auto-generated by `rebar3 compile`. Pinned in each tutorial with deps.
- **Elm**: `elm.json` pins exact versions (no separate lockfile). The Elm compiler resolves at install time.

## Fat Binary Distribution

For producing single-file executables from these tutorials, see:

- **Elixir**: [Burrito](https://github.com/burrito-elixir/burrito) — wraps mix release into a self-extracting exe (6-40 MB)
- **Erlang**: [warp-packer](https://github.com/dgiagio/warp) — wraps rebar3 release into a single binary
- **Elm**: [Tauri](https://tauri.app/) — wraps compiled JS in native WebView (3-10 MB desktop app)

See the language summary docs (`BEAM.md`, `ELIXIR.md`, `ERLANG.md`, `ELM.md`) in the project root for details.
