# The BEAM VM

The BEAM (Bogdan/Björn's Erlang Abstract Machine) is the virtual machine that runs Erlang, Elixir, Gleam, and other BEAM languages. It was designed at Ericsson in the 1980s for telecom switches requiring 99.999% uptime.

## Core Architecture

**Processes** — BEAM processes are not OS threads. They are lightweight (~0.5 KB initial heap), preemptively scheduled, and fully isolated. A typical node can run millions of them. Each process has its own heap and garbage collector — no stop-the-world pauses.

**Schedulers** — One scheduler thread per CPU core, each with a run queue. Processes are preempted after ~4000 "reductions" (roughly function calls), ensuring no process monopolizes a core. This gives soft real-time guarantees without cooperative yielding.

**Message Passing** — Processes communicate exclusively by copying messages to each other's mailboxes. No shared mutable state means no locks, no races, and no defensive programming around concurrent access.

## Error Handling & "Let it Crash"

BEAM's error philosophy is fundamentally different from most runtimes:

**No defensive error handling** — instead of try/catch everywhere, processes are designed to crash on unexpected conditions. A supervisor detects the crash and restarts the process in a known-good state. This eliminates entire categories of bugs: corrupted state, half-recovered errors, and error-handling code that is itself buggy.

**Three error classes** on the VM level:
- `:error` — runtime errors (badmatch, function_clause, badarith). These crash the process.
- `:exit` — explicit process termination. Supervisors trap these.
- `:throw` — non-local returns (rarely used; a flow-control escape hatch).

**Process linking & monitoring** — Processes can be linked (bidirectional: if one dies, the other dies too) or monitored (unidirectional: the monitor receives a `{:DOWN, ...}` message). Supervisors use links. Application code typically uses monitors.

**Supervisor restart strategies:**
- `one_for_one` — restart only the crashed child
- `one_for_all` — restart all children (for interdependent processes)
- `rest_for_one` — restart the crashed child and all children started after it
- Max restarts per time window — if exceeded, the supervisor itself crashes (escalation)

**Retry is structural, not ad-hoc** — You don't write retry loops. You configure a supervisor with max restart intensity (e.g., 3 restarts in 5 seconds). The supervisor handles retry automatically. If the process keeps crashing, escalation propagates up the supervision tree until the system either self-heals or a human is alerted.

## Fault Tolerance

**Supervision trees** — Supervisors supervise other supervisors, forming a tree. The root supervisor is started by the application. If a subtree keeps crashing (max restarts exceeded), its supervisor crashes too, escalating up the tree. This gives self-healing behavior.

**Process isolation** — A crashing process cannot corrupt another process's memory. The crashed process's heap is simply freed. There is no equivalent of a segfault bringing down the whole runtime.

**Graceful degradation** — Parts of the system can fail while the rest continues serving. A database connection pool can lose connections and recover transparently. A failing microservice agent doesn't take down the gateway.

## Hot Code Reloading

BEAM holds two versions of a module simultaneously (current and old). Running processes on the old version continue until they make an external call, at which point they switch to the new version. This enables zero-downtime deployments — critical for telecom, financial systems, and long-running AI agents.

## Distribution

BEAM nodes can cluster over TCP. Processes on different nodes communicate with the same `send`/`receive` primitives as local processes. `net_kernel` handles node discovery and connection. Distributed Erlang uses a shared cookie for authentication.

Key distribution primitives:
- `Node.connect/1` / `net_kernel:connect_node/1` — join a cluster
- `GenServer.call({name, node}, msg)` — transparent remote calls
- `:global` / `:pg` — cluster-wide process registries

## I/O and Networking

BEAM uses an internal event loop (similar to epoll/kqueue) for non-blocking I/O. Network sockets are managed by the VM, not by OS threads. This is why Phoenix can hold 2M+ concurrent WebSocket connections on a single machine.

## Special Features

**ETS (Erlang Term Storage)** — In-memory key-value tables shared across processes on a single node. Read access is lock-free. Used for caches, rate limiters, and shared counters without GenServer bottlenecks.

**Ports and NIFs** — Ports let BEAM talk to external OS processes via stdin/stdout. NIFs (Native Implemented Functions) call C/Rust code directly in the scheduler thread — dangerous (a NIF crash kills the VM) but fast. Dirty schedulers exist for long-running NIFs that would block the normal scheduler.

**Observer** — Built-in GUI for inspecting running systems: process trees, message queues, memory usage, ETS tables, and supervision hierarchies. Available with `:observer.start()`.

**Match specifications** — Compiled pattern-matching expressions that run inside ETS or trace calls. Used by tools like Recon for production debugging without redeploying code.

## Suitability for AI Agents

| Requirement | BEAM Answer |
|---|---|
| Concurrent tool calls | Spawn a process per tool call, all run in parallel |
| Fault isolation | A failing tool call crashes its process, not the agent |
| Automatic retry | Supervisor restarts crashed tool-call processes automatically |
| Stateful agents | GenServer holds agent state with built-in persistence hooks |
| Streaming responses | Processes + message passing are natural for token streaming |
| Multi-agent systems | Each agent is a process (or supervision tree), communicating via messages |
| Scaling | Distribute agents across nodes transparently |
| Timeout handling | `receive ... after Timeout` and `GenServer.call/3` timeouts are first-class |

## Network Protocol Support

| Protocol | Server | Client | Notes |
|---|---|---|---|
| **HTTP/1.1** | Cowboy, Bandit | httpc (OTP), Mint, Finch, Gun | Mature, production-proven |
| **HTTP/2** | Cowboy 2.x+, Bandit | Mint, Finch, Gun | Bandit scores 100% on h2spec |
| **HTTP/3 (QUIC)** | In progress (Cowboy + Quicer) | Quicer (NIF to MsQuic) | QUIC transport production-ready via Quicer (EMQX). Full HTTP/3 server not yet in stable Cowboy release |
| **WebSocket** | Cowboy, Bandit (via WebSock) | Gun, Fresh | Phoenix Channels provides high-level abstraction |
| **gRPC** | grpc (Elixir), grpcbox (Erlang) | Same | Unary, streaming, bidirectional |
| **SSE** | Plug chunked responses, Cowboy stream_reply | N/A | No special library needed — use chunked encoding |
| **Unix Domain Sockets** | gen_tcp with `{local, Path}` | Same | Supported since OTP 19. Works for Erlang distribution too |

## Inter-Process Communication

BEAM has the richest built-in IPC of any mainstream runtime:

| Mechanism | Scope | Pattern |
|---|---|---|
| `send`/`receive` | Local/distributed | Async message to PID |
| `GenServer.call/cast` | Local/distributed | Sync request-reply / async fire-and-forget |
| `Registry` (Elixir) | Local only | ETS-backed, partitioned, via-tuple naming |
| `:pg` (OTP 25+) | Cluster-wide | Process groups — join/leave/members |
| `:global` | Cluster-wide | Singleton name registration with global lock |
| `Phoenix.PubSub` | Cluster-wide | Topic-based pub/sub (built on `:pg`) |
| `Syn` | Cluster-wide | Scalable registry + groups with metadata, net-split handling |

All mechanisms work identically from Erlang and Elixir (same VM primitives).

## TTY & Terminal Support

**Built-in:**
- `io:columns/0`, `io:rows/0` — terminal size detection
- `IO.ANSI` (Elixir) — color, bold, cursor movement, clear screen
- `IO.ANSI.enabled?/0` — checks if stdout is a TTY
- **OTP 28+ raw mode** — native raw terminal input (keystrokes without Enter, no echo). First time BEAM supports this without C NIFs.

**Libraries:**
- **TermUI** (v1.0.0-rc, 2026) — full-screen TUI framework inspired by BubbleTea/Ratatui. Elm Architecture, widget library, constraint layout, keyboard+mouse, 60 FPS differential rendering, true-color RGB. The most capable current option.
- **Owl** (v0.13.0) — CLI enhancement toolkit: colored output, progress bars, tables, select menus. Top-to-bottom flow (not full-screen).
- **Garnish** — TUI via SSH (built on OTP's `:ssh`). No NIF dependency.

**Missing:** No terminfo/termcap library. No `$COLORTERM` detection. Terminal capability is limited to ANSI/VT100 assumption.

## Container & cgroups Awareness

**CPU scheduling (OTP 23+):**
- BEAM **automatically detects cgroup CPU quotas** and sets scheduler count accordingly: `num_schedulers = cpu_quota / cpu_period`
- `docker run --cpus 2` → BEAM starts 2 online schedulers
- Works with cgroups v1 and v2
- `--cpu-shares` is **not** taken into account (only hard quotas/limits)
- Manual override: `+S 4:4` flag

**Memory:**
- `memsup` (from `os_mon`) monitors system memory, but may report **host** memory in containers depending on kernel version
- No built-in cgroup memory limit reading — read `/sys/fs/cgroup/memory.max` (v2) or `/sys/fs/cgroup/memory/memory.limit_in_bytes` (v1) directly with `File.read/1`
- BEAM memory allocators (`+MBas`, `+MMmcs`) manage internal heap organization but are not cgroup-aware
- Set `ERL_CRASH_DUMP_BYTES` to prevent crash dumps from filling container storage

**Known issues:**
- Inconsistent CPU quota behavior across OTP versions in Docker (OTP issue #8450)
- Cannot determine quota when `/proc/self/mountinfo` lacks optional fields (#7401)

## Binary Distribution & Fat Binary Options

### Single-File Fat Binary Summary

| Method | Size | Self-Contained? | Cross-Compile? | Startup |
|---|---|---|---|---|
| **Burrito** (Elixir) | 6-20 MB (CLI), 20-40 MB (Phoenix) | Yes (bundles ERTS) | Yes (Zig, all platforms from one host) | ~100-500ms warm, seconds cold (extraction) |
| **warp-packer** (Erlang) | Similar to Burrito | Yes (bundles ERTS) | Linux primarily | Similar |
| **mix release** | Directory tree | Yes (bundles ERTS) | No (use Docker) | ~100-500ms |
| **rebar3 release** | Directory tree | Yes (bundles ERTS) | No (use Docker) | ~100-500ms |
| **escript** (either) | Small single file | No (needs Erlang) | N/A | ~100ms |

### Elixir
- **Burrito** (v1.5, ~1300 stars) — the primary option. Wraps `mix release` + ERTS into a self-extracting exe using Zig. Extracts to `~/.local/share/` (Linux), `~/Library/Application Support/` (macOS), `%APPDATA%` (Windows). Caches by version; auto-cleans old versions. Supports `:linux_musl` for static binaries. Has plugin system for licensing/auto-update.
- `mix release` — directory with ERTS. Not a single file, but deploy-anywhere. Use Docker for cross-platform builds.
- escript — single file, but requires Erlang pre-installed.
- **Bakeware** — predecessor to Burrito. **Archived Sep 2024.**

### Erlang
- `rebar3 release` (relx) — directory with ERTS. Same concept as mix release.
- **warp-packer** — general-purpose tool that compresses a release directory into one self-extracting exe. Works well with rebar3 releases.
- escript — requires Erlang on target. No OTP supervision trees.
- No Erlang-specific Burrito equivalent; wrap via Elixir project or use warp-packer.

### Cross-compilation
- `mix release` / `rebar3 release` — cannot cross-compile natively. Build in Docker matching the target.
- **Burrito** — cross-compiles for all targets from one host via Zig. This is its killer feature.
- **Nerves** — full cross-compilation toolchains for embedded targets (RPi, BeagleBone, etc.)

### Platform Installers
- **macOS**: Burrito exe in a `.app` bundle + `hdiutil` for `.dmg`. Tauri produces `.dmg` natively. Code signing + notarization required for distribution.
- **Windows**: Burrito `.exe` wrapped in NSIS/Inno Setup/WiX MSI. Tauri produces `.msi` and `.exe` natively.
- **Linux**: AppImage (single file, no install), Flatpak (sandboxed), Snap (Ubuntu-centric). Tauri produces `.deb`, `.rpm`, `.AppImage`.
- **Docker**: Alpine multi-stage + mix release → ~20-50 MB images.

## WebAssembly (WASM) Support

- **AtomVM** (v0.6.6, active) — tiny BEAM implementation in C. Compiles to WASM and runs BEAM bytecode in the browser. Subset of OTP. Also targets ESP32, STM32, RPi Pico.
- **Popcorn** (2025, Software Mansion) — builds on AtomVM-WASM to provide Elixir-in-the-browser with JS interop. Powers the Elixir Language Tour. Officially endorsed by the Elixir team.
- **Firefly/Lumen** — ambitious Rust-based BEAM-to-WASM AOT compiler. **Archived June 2024, never released.**
- **Elm** — compiles to JS only. No WASM backend. Experimental proof-of-concepts exist (elm_c_wasm) but nothing production-ready.

## Desktop Application Development

| Approach | Technology | Status |
|---|---|---|
| **wx** (OTP built-in) | wxWidgets binding for Erlang. Observer is built with it. | Stable, ships with OTP |
| **Scenic** | Pure Elixir OpenGL-based UI framework | Slow (0.12-rc since Jun 2024) |
| **Desktop** (elixir-desktop) | Phoenix LiveView in native WebView window | Low activity (v1.5.3, Mar 2024) |
| **LiveView Native** | Phoenix LiveView rendering to SwiftUI / Jetpack Compose | Active (DockYard). SwiftUI v0.4-rc, Jetpack v0.3 |
| **Livebook Desktop** | Livebook bundled as macOS/Windows app | Very active (v0.19.2, Mar 2026) |
| **Elm + Tauri** | Elm compiled to JS, wrapped in Tauri (Rust + system WebView) | Community templates, ~10 MB binaries |
| **Elm + Electron** | Elm in Electron | Works but heavy (~200 MB) |

### Tcl/Tk Integration

Erlang had **gs** (Graphics System), a Tcl/Tk-based GUI library that shipped with OTP. Removed in **OTP 20 (2017)** in favor of wx (wxWidgets). Before gs, **etk** provided direct Tk 4.2 bindings.

Current Tcl/Tk options are minimal:
- **etclface** — Tcl C extension using `erl_interface` to join a Distributed Erlang cluster from Tcl/Tk
- **portcl** — Erlang port to Tcl scripts (`wish`/`tclsh`); formalizes the pattern of driving Tk GUIs via stdin/stdout
- Neither is on Hex.pm. **No Elixir Tcl/Tk wrapper exists.**
- The practical approach: open an Erlang port to `wish`, send Tcl commands as strings, receive events back. Works but is niche.

## Notable Software Built on BEAM

| Project | Language | Scale/Description |
|---|---|---|
| **WhatsApp** | Erlang | 2B+ users, ~100B messages/day, ~50 engineers |
| **Discord** | Elixir | 11M concurrent users, millions of messages/sec |
| **Ericsson telecom** | Erlang | 5G/4G/3G infrastructure, nine-nines uptime |
| **Cisco** | Erlang | ~2M devices/year, ~90% of internet traffic touches Erlang routers |
| **RabbitMQ** | Erlang | Most widely deployed open-source message broker |
| **EMQX** | Erlang | 100M concurrent MQTT connections (IoT) |
| **Nintendo NPNS** | Erlang (ejabberd) | 10M concurrent connections, 2B messages/day |
| **Pinterest** | Elixir | 14k notifications/sec on 15 servers |
| **Supabase Realtime** | Elixir | Global distributed WebSocket cluster |
| **Plausible Analytics** | Elixir | Privacy-friendly analytics, 60M+ pageviews/month |
| **Klarna** | Erlang | Europe's largest fintech, core payment processing |
| **Goldman Sachs** | Erlang | High-frequency trading, real-time market data |
| **CouchDB** | Erlang | Apache distributed document database |
| **Riak** | Erlang | Distributed key-value database (Dynamo-inspired) |

## Weaknesses

- **CPU-bound work**: BEAM is optimized for I/O-bound concurrency, not number crunching. Use NIFs (Rust/C) or Nx for heavy computation.
- **Startup time**: ~100ms cold start. Not ideal for short-lived serverless functions.
- **Ecosystem size**: Smaller than JVM/Node.js ecosystems, though growing steadily.
- **No shared memory**: Message copying between processes can be costly for large payloads (mitigated by ETS and binary reference counting for large binaries).
- **Distribution security**: Distributed Erlang's cookie-based auth is coarse-grained. Use TLS or VPN overlays for production clusters.
- **No HTTP/3 yet**: QUIC transport exists (Quicer) but full HTTP/3 server support isn't in stable Cowboy.
- **No terminfo**: Terminal capability detection is rudimentary (TTY check only, no terminfo database).
- **Desktop GUI**: wx is the only mature option; no modern native UI framework rivals Qt/GTK/SwiftUI.

## Further Reading

- [The BEAM Book](https://blog.stenmans.org/theBeamBook/) — deep dive into VM internals
- [Erlang Runtime System (ERTS)](https://www.erlang.org/doc/system/system_architecture.html) — official docs
