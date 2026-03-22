# Elixir

Elixir is a dynamic, functional language built on the BEAM VM, created by José Valim in 2011. It provides Ruby-inspired syntax, powerful metaprogramming, and seamless access to the entire Erlang/OTP ecosystem.

## Language Features

- **Pipe operator** — `data |> transform() |> filter() |> format()` for readable data pipelines
- **Pattern matching** — destructuring in function heads, case, with, and assignment
- **Macros** — compile-time metaprogramming (AST manipulation); the language itself is built with macros
- **Protocols** — ad-hoc polymorphism (like type classes or interfaces) without modifying existing types
- **Structs** — named maps with compile-time field checking
- **Comprehensions** — `for x <- list, x > 0, do: x * 2` with generators, filters, and `:into` collectors
- **Sigils** — `~r/regex/`, `~w(word list)`, extensible for custom literals
- **With** — `with {:ok, x} <- step1(), {:ok, y} <- step2(x), do: {:ok, y}` for clean happy-path chaining
- **Documentation** — first-class `@doc` and `@moduledoc` with ExDoc generating beautiful HTML
- **Behaviours** — explicit interface contracts (`@callback` + `@behaviour`) with compile-time warnings for missing implementations

## Type System

Elixir is **dynamically typed** but has a rich and evolving type story:

### Current State
- **Runtime typing** — types are checked when code executes, not at compile time
- **Typespecs** — `@spec function_name(arg_type) :: return_type` annotations used by tools but not enforced by the compiler
- **Dialyzer** — inherited from Erlang; success-typing analysis with zero false positives. Catches definite type errors but misses many real ones.
- **Guards** — `when is_binary(name)` in function heads provide runtime type dispatch

### Gradual Typing (Elixir 1.18+)
As of Elixir 1.18, a **set-theoretic type system** is being integrated into the compiler:
- The compiler infers types from patterns, guards, and usage
- Type violations produce **warnings** (not errors, yet) during compilation
- Union types, intersection types, and negation types are supported
- This is opt-in and incremental — existing code continues to work
- Expected to become stricter over future releases

### Strengths
- Pattern matching provides structural type checking at runtime — wrong shapes crash early
- Tagged tuples (`{:ok, value}` / `{:error, reason}`) make error paths explicit and compiler-visible
- Structs give you named, validated map shapes
- The gradual typing initiative will eventually close the gap with statically typed languages
- Protocols provide type-directed dispatch without inheritance hierarchies

### Weaknesses
- Today, Dialyzer is the main static analysis tool and it's slow + hard to set up
- No sum types / discriminated unions at the language level (you use atoms + tuples by convention)
- Map keys are unchecked at compile time (structs help, but nested access is still dynamic)
- Refactoring without type safety requires strong test coverage

## Error Handling

Elixir provides multiple error-handling mechanisms, each for a different situation:

### 1. Tagged Tuples (primary pattern)
```elixir
case File.read("data.txt") do
  {:ok, data}      -> process(data)
  {:error, :enoent} -> Logger.warn("file not found")
  {:error, reason}  -> Logger.error("read failed: #{inspect(reason)}")
end
```
Most Elixir functions return `{:ok, result}` or `{:error, reason}`. The companion `!` convention (`File.read!`) raises an exception instead — use it when failure is truly unexpected.

### 2. The `with` Construct (happy-path chaining)
```elixir
with {:ok, data} <- File.read(path),
     {:ok, parsed} <- Jason.decode(data),
     {:ok, user} <- validate(parsed) do
  {:ok, user}
else
  {:error, :enoent} -> {:error, "file not found"}
  {:error, %Jason.DecodeError{}} -> {:error, "invalid JSON"}
  {:error, reason} -> {:error, reason}
end
```
`with` chains multiple `{:ok, _}` / `{:error, _}` operations cleanly, short-circuiting on the first non-match.

### 3. Exceptions (try/rescue)
```elixir
try do
  dangerous_operation()
rescue
  e in ArgumentError -> handle_arg_error(e)
  e in RuntimeError  -> handle_runtime_error(e)
catch
  :exit, reason -> handle_exit(reason)
  :throw, value -> handle_throw(value)
end
```
Exceptions exist but are reserved for **unexpected programmer errors**, not expected failure paths. The Elixir community convention is: **use tagged tuples for expected errors, exceptions for bugs.**

### 4. "Let it Crash" (supervision)
For unexpected failures, don't rescue — let the process crash. A Supervisor restarts it:
```elixir
children = [
  {MyWorker, restart: :permanent},  # always restart
  {MyCache, restart: :transient},   # restart only on abnormal exit
]
Supervisor.start_link(children, strategy: :one_for_one)
```

### Retry Patterns

**Supervisor-level retry** — configure max restarts:
```elixir
Supervisor.start_link(children,
  strategy: :one_for_one,
  max_restarts: 3,      # max 3 crashes
  max_seconds: 5         # within 5 seconds
)
```

**Application-level retry** — for operations like HTTP calls:
```elixir
defp fetch_with_retry(url, retries \\ 3)
defp fetch_with_retry(_url, 0), do: {:error, :max_retries}
defp fetch_with_retry(url, retries) do
  case HTTPClient.get(url) do
    {:ok, response} -> {:ok, response}
    {:error, _} ->
      Process.sleep(1000 * (4 - retries))  # backoff
      fetch_with_retry(url, retries - 1)
  end
end
```

**Task.Supervisor for isolated retries:**
```elixir
Task.Supervisor.async_nolink(MyTaskSup, fn -> risky_work() end)
|> Task.yield(5000)    # wait up to 5s
|> case do
  {:ok, result} -> result
  {:exit, _reason} -> fallback()  # task crashed
  nil -> Task.shutdown(task)       # task timed out
end
```

## Concurrency Primitives

```elixir
# Spawn a process
pid = spawn(fn -> do_work() end)

# Tasks for structured concurrency
task = Task.async(fn -> fetch_url(url) end)
result = Task.await(task, 5_000)  # 5s timeout

# Parallel stream processing
urls
|> Task.async_stream(&fetch/1, max_concurrency: 10, timeout: 30_000)
|> Enum.to_list()

# Stateful process
GenServer.start_link(MyAgent, initial_state)
GenServer.call(pid, :get_state, 10_000)  # 10s timeout
```

## Ecosystem

| Tool | Purpose |
|---|---|
| **Mix** | Build tool: create, compile, test, release, manage deps |
| **Hex.pm** | Package registry (~20k packages) |
| **Phoenix** (v1.8) | Web framework (MVC, channels, LiveView) |
| **LiveView** | Server-rendered reactive UIs without JavaScript |
| **Ecto** | Database wrapper and query DSL (changesets for validation) |
| **Bandit** (v1.10) | Pure Elixir HTTP server — HTTP/1.1, HTTP/2, WebSocket. Default in Phoenix 1.8. |
| **Finch** / **Req** | HTTP client (HTTP/1.1 + HTTP/2) built on Mint with connection pooling |
| **Nx** | Numerical computing (tensors, autograd, GPU via EXLA) |
| **Bumblebee** | Pre-trained ML models (Llama, Whisper, Stable Diffusion) on BEAM |
| **ExUnit** | Built-in test framework with async support |
| **Nerves** | IoT/embedded firmware framework |
| **Broadway** | Concurrent data processing pipelines (SQS, Kafka, RabbitMQ) |
| **Oban** | Background job queue with persistence, retries, cron |

## Network & Protocol Support

| Protocol | Server | Client | Notes |
|---|---|---|---|
| **HTTP/1.1** | Bandit, Plug+Cowboy | Finch, Req, Mint, :httpc | Mature |
| **HTTP/2** | Bandit (100% h2spec), Cowboy | Mint, Finch, Req | Bandit is 1.5x faster than Cowboy for h2 |
| **HTTP/3 (QUIC)** | Not yet (Cowboy+Quicer WIP) | Quicer NIF (MsQuic) | QUIC transport usable, full HTTP/3 not in stable release |
| **WebSocket** | Bandit/Cowboy via WebSock, Phoenix Channels | Fresh (Mint-based), Gun | Phoenix Channels adds topics, presence, rooms |
| **gRPC** | `grpc` (v0.11) | Same | Unary + all streaming types, HTTP transcoding |
| **SSE** | `Plug.Conn.chunk/2` | N/A | Set `content-type: text/event-stream`, stream with `chunk/2` |
| **Unix sockets** | `:gen_tcp` with `{:local, path}` | Same | OTP 19+. Works for distribution too |

## Inter-Process Communication

| Mechanism | Scope | Use Case |
|---|---|---|
| `send/receive` | Local + distributed | Direct async messaging to PIDs |
| `GenServer.call/cast` | Local + distributed | Sync request-reply / async fire-and-forget |
| `Registry` | Local only | ETS-backed, partitioned, via-tuple process naming |
| `:pg` | Cluster-wide | Process groups (join/leave/members) |
| `Phoenix.PubSub` | Cluster-wide | Topic-based pub/sub (built on `:pg`) |
| ETS | Local (shared read) | Lock-free reads, concurrent writes, caches/counters |

## TTY & Terminal Support

**Built-in:**
- `IO.ANSI` — colors, bold, cursor movement, clear screen. `IO.ANSI.enabled?/0` detects TTY.
- `io:columns/0`, `io:rows/0` — terminal size detection (returns `{:error, :enotsup}` on non-TTY)
- **OTP 28+ raw mode** — native keystroke-at-a-time input without C NIFs. Game-changer for TUI apps.

**Libraries:**
- **TermUI** (v1.0.0-rc) — full-screen TUI framework. Elm Architecture, widgets (gauges, tables, sparklines), constraint layout, keyboard+mouse, 60 FPS, true-color. Inspired by BubbleTea (Go) and Ratatui (Rust).
- **Owl** (v0.13) — CLI toolkit: colored output, progress bars, input prompts, tables, select menus. Top-to-bottom flow.
- **Garnish** — TUI over SSH (built on OTP `:ssh`). No NIF deps.

**Missing:** No terminfo library. No `$COLORTERM` truecolor detection.

## Container Awareness

- **CPU**: OTP 23+ auto-detects cgroup CPU quotas → sets scheduler count. `docker run --cpus 2` → 2 schedulers.
- **Memory**: `memsup` may report host memory; read `/sys/fs/cgroup/memory.max` directly for container limits.
- **Releases**: `mix release` produces self-contained binaries ideal for minimal container images (no Elixir/Erlang install needed).
- **Health checks**: Plug routes for `/healthz`, `/readyz` integrate with Kubernetes probes (see tutorial 09).
- **Metrics**: TelemetryMetricsPrometheus exposes `/metrics` for Prometheus scraping in container orchestrators.

## Special Features

- **Macros & DSLs** — Elixir's `defmacro` enables domain-specific languages. Ecto queries look like SQL, Phoenix routes look like a routing table, ExUnit tests use `assert` with rich error messages — all are macros.
- **LiveView** — server-rendered reactive UIs over WebSocket. No JavaScript framework needed. State lives on the server (in a process), diffs are pushed to the browser. Ideal for AI agent dashboards.
- **Nx + EXLA** — numerical computing with tensor operations that compile to XLA (Google's accelerator compiler). Run ML inference on CPU/GPU without leaving the BEAM.
- **`mix release`** — compile a self-contained binary with the Erlang runtime. No language installation needed on the target machine.
- **Umbrella projects** — monorepo support built into Mix. Multiple applications in one repo with shared dependencies.
- **`@derive` and protocols** — automatic protocol implementations (e.g., `@derive Jason.Encoder` makes a struct JSON-serializable in one line).
- **Process dictionary** — per-process mutable storage. Generally discouraged, but useful for Logger metadata and OpenTelemetry context propagation.

## Binary Distribution & Fat Binary Options

### `mix release` (built-in since Elixir 1.9)
Self-contained directory with compiled `.beam` files + ERTS. No Elixir/Erlang needed on target. `steps: [:assemble, :tar]` produces a tarball. Not a single executable.

### Burrito (v1.5, ~1300 stars) — the single-binary solution
Wraps `mix release` + ERTS into a **single self-extracting executable** using Zig:
- **Binary sizes**: ~6.5 MB (macOS CLI), ~16 MB (Linux CLI), 20-40 MB (Phoenix app)
- **Startup**: ~100-500ms warm (cached). First run: extraction + boot (seconds).
- **Extraction**: to `~/Library/Application Support/` (macOS), `~/.local/share/` (Linux), `%APPDATA%` (Windows). Caches by version, auto-cleans old versions.
- **Cross-compilation**: builds for macOS/Linux/Windows/musl from any host via Zig.
- **NIFs**: auto-recompiled with Zig as C compiler. Rustler Precompiled NIFs bundled inside.
- **musl support**: `:linux_musl` target for static binaries (Alpine, scratch containers).
- **Plugin system**: inject custom Zig code for licensing, auto-updates, pre-extraction hooks.
- **Limitations**: `System.argv()` returns empty (use `Burrito.Util.Args`); Phoenix needs `PHX_SERVER=1`; Windows needs MSVC Runtime; macOS needs code signing.

### escript
Single file, but **requires Erlang on target**. No ERTS bundled, no supervision trees. Good for dev tools, not end-user distribution.

### Bakeware — **Archived Sep 2024.** Don't use.

### Minimal Docker containers
Alpine multi-stage build with `mix release`: ~20 MB (simple app), ~50 MB (Phoenix). True `scratch` not practical (BEAM needs libc + openssl).

### Platform installers
- **macOS**: Burrito exe in `.app` bundle → `.dmg` via `hdiutil`. Tauri produces `.dmg` natively.
- **Windows**: Burrito `.exe` wrapped in NSIS/Inno Setup/WiX MSI. Tauri produces `.msi`/`.exe`.
- **Linux**: Tauri produces `.deb`, `.rpm`, `.AppImage`. Burrito binary inside AppImage also works.

## WASM Support

- **Popcorn** (2025, Software Mansion) — runs Elixir in the browser via AtomVM compiled to WASM. JS interop, process spawning, even client-side Elixir compilation. Powers the official Elixir Language Tour. Endorsed by the Elixir core team.
- **AtomVM** (v0.6.6) — tiny BEAM in C, compiles to WASM. Subset of OTP. Also targets microcontrollers (ESP32, STM32).
- **Firefly/Lumen** — Rust-based BEAM-to-WASM AOT compiler. **Archived June 2024, never released.**

## Desktop Application Development

| Approach | Description | Status |
|---|---|---|
| **Scenic** (v0.11) | Pure Elixir OpenGL framework. Scene graph, no browser. Created by ex-Xbox Live architect. | Stalled (0.12-rc since Jun 2024) |
| **Desktop** (elixir-desktop, v1.5.3) | Phoenix LiveView in native WebView (wxWidgets). Targets macOS/Linux/Windows/iOS/Android. | Low activity (Mar 2024) |
| **LiveView Native** | Phoenix LiveView rendering SwiftUI (Apple) / Jetpack Compose (Android). Server-driven native UI. | Active (DockYard). SwiftUI v0.4-rc, Jetpack v0.3 |
| **Livebook Desktop** (v0.19.2) | Livebook bundled as macOS/Windows desktop app. Uses elixir-desktop under the hood. | Very active (Mar 2026) |
| **Burrito + CLI** | Distribute a CLI/TUI app as a single native binary. | Production-ready |
| **wx** (via Erlang) | Call OTP's wxWidgets bindings directly from Elixir. Observer is built with it. | Stable, ships with OTP |

### Tcl/Tk Integration

No Elixir-specific Tcl/Tk wrapper exists. Erlang's old `gs` (Tk-based GUI) was removed in OTP 20. You can use **portcl** (Erlang port to `wish`) from Elixir via Erlang interop, but this is niche. For GUI work, use wx, Scenic, LiveView, or elixir-desktop instead.

## Notable Software Built with Elixir

| Project | Scale/Description |
|---|---|
| **Discord** | 11M concurrent users, millions of messages/sec. 5 engineers run 20+ Elixir services. |
| **Pinterest** | 14k notifications/sec on 15 servers (half the servers of prior Java system) |
| **Bleacher Report** | Billions of monthly pageviews. Migrated from Rails to handle live sports traffic spikes. |
| **PepsiCo** | Marketing automation and logistics data pipelines |
| **Brex** | Fintech (corporate cards). Backend on Elixir/Phoenix + Kubernetes. |
| **Remote.com** | Global HR/payroll platform (60+ countries). Elixir/Phoenix + PostgreSQL. |
| **Supabase Realtime** | Global distributed Elixir cluster powering Supabase's WebSocket layer |
| **Plausible Analytics** | Privacy-friendly analytics. 60M+ pageviews/month. 20k+ GitHub stars. |
| **Fly.io** | Cloud infrastructure platform. First-class distributed Elixir support. |
| **Livebook** | Interactive Elixir notebooks (like Jupyter). By the Elixir core team. 5k+ stars. |
| **TeslaMate** | Self-hosted Tesla data logger. 7k+ stars. |
| **Phoenix Framework** | The web framework itself. 2M+ concurrent WebSocket connections. |
| **Membrane Framework** | Multimedia pipelines (audio/video, WebRTC, streaming) |
| **Nerves** | Embedded/IoT firmware platform (Raspberry Pi, industrial devices) |
| **Oban** | Background job queue backed by PostgreSQL. Ubiquitous in Elixir apps. |

## AI Agent Suitability

| Requirement | Elixir Solution |
|---|---|
| Agent state management | GenServer — holds conversation history, tool results, config |
| Parallel tool execution | Task.async_stream — fan out N tool calls, collect results with timeouts |
| Fault isolation | Supervisor — if a tool call crashes, restart and retry automatically |
| Streaming LLM responses | Process mailbox — stream tokens as messages |
| Multi-agent orchestration | Each agent is a supervised process tree, communicating via messages |
| Real-time UI | Phoenix LiveView — stream agent output to browser in real-time |
| ML inference | Nx + Bumblebee — run models directly on BEAM |
| HTTP API | Plug/Phoenix — expose agent as API with OpenAPI spec |
| Background jobs | Oban — persistent job queue with retries and dead-letter for async agent tasks |
| Timeout handling | GenServer.call/3, Task.await/2, and receive...after all accept timeouts |

## Why Elixir Over Erlang

- **Syntax** — more approachable for developers from Ruby/Python backgrounds
- **Macros** — enable DSLs (Ecto queries, Phoenix routes, ExUnit tests)
- **Tooling** — Mix, Hex, ExDoc, ElixirLS (language server) are polished
- **Community** — larger, more active, better learning resources
- **Same runtime** — compiles to BEAM bytecode, can call any Erlang module directly
- **Gradual typing** — Elixir is investing in a type system; Erlang is not

## Weaknesses

- **Not for CPU-heavy work** — use Nx/NIFs for number crunching
- **Dynamic typing** — gradual typing is landing but still early; today you rely on Dialyzer + tests
- **Smaller ecosystem** — fewer libraries than Node.js/Python, though quality is high
- **Learning curve** — functional + OTP concepts take time for imperative programmers
- **No algebraic data types** — tagged tuples are convention, not compiler-enforced
- **Compilation speed** — large projects can be slow to compile (improving with Elixir 1.19+)
