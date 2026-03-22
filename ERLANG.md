# Erlang

Erlang is a functional, dynamically typed language created at Ericsson in 1986 for building fault-tolerant telecom systems. It runs on the BEAM VM and comes bundled with OTP (Open Telecom Platform), a set of battle-tested libraries and design patterns.

## Language Features

- **Pattern matching** everywhere — function heads, case expressions, receive blocks
- **Immutable data** — variables are single-assignment (rebinding is a compile error)
- **Atoms** — lightweight constants like `ok`, `error`, `undefined`
- **Binaries** — first-class binary data with pattern matching (`<<Header:4/bytes, Rest/binary>>`)
- **List comprehensions** — `[X*2 || X <- [1,2,3], X > 1]`
- **Tail call optimization** — recursive loops without stack overflow
- **Prolog-inspired syntax** — periods end statements, commas separate expressions, semicolons separate clauses
- **Bit syntax** — parse and construct binary protocols at the bit level: `<<Version:2, Flags:6, Payload/binary>>`
- **Records** — compile-time named tuples (replaced by maps in modern code, but still ubiquitous in OTP)

## Type System

Erlang is **dynamically typed** — types are checked at runtime, not compile time.

**What exists:**
- **No static type checker in the compiler** — any term can be passed anywhere. Runtime pattern match failures crash the process (which is by design — "let it crash").
- **Type specs** — optional annotations like `-spec greet(binary()) -> binary()`. Not enforced by the compiler.
- **Dialyzer** — a static analysis tool using "success typing" (the opposite of traditional type inference). Dialyzer only reports definite errors — it never has false positives, but misses some real bugs. It infers types from code and checks specs against actual behavior.
- **Gradualizer** — community project for gradual typing; still experimental.
- **eqWAlizer** — Meta/WhatsApp's type checker; more aggressive than Dialyzer, closer to traditional static typing.

**Strengths:**
- Pattern matching acts as a lightweight runtime type system — malformed data crashes early and loudly
- Tagged tuples (`{ok, Value}`, `{error, Reason}`) are the universal convention, making error paths explicit
- Dialyzer catches class-of-type errors with zero false positives

**Weaknesses:**
- No compile-time guarantee that a function receives the right types
- Refactoring large codebases is risky without Dialyzer discipline
- No algebraic data types — you use atoms/tuples by convention, not enforcement
- Type specs are documentation, not contracts

## Error Handling

Erlang has three error mechanisms:

### 1. Tagged Return Tuples (primary pattern)
```erlang
case file:read("data.txt") of
    {ok, Data}      -> process(Data);
    {error, enoent} -> log("file not found");
    {error, Reason} -> log(Reason)
end.
```
This is the dominant pattern. Functions return `{ok, Result}` or `{error, Reason}`. Callers pattern-match and handle both paths. Unhandled cases crash the process (by design).

### 2. Exceptions (try/catch)
```erlang
try
    dangerous_operation()
catch
    error:badarg   -> handle_badarg();
    throw:Reason   -> handle_throw(Reason);
    exit:Reason    -> handle_exit(Reason)
end.
```
Three classes: `error` (runtime bugs like badmatch), `throw` (explicit non-local returns), `exit` (process termination signals). In practice, `try/catch` is used at boundaries (HTTP handlers, message processors) but not deep in business logic.

### 3. "Let it Crash" (the BEAM way)
The idiomatic approach: don't catch errors you can't meaningfully handle. Let the process crash. A supervisor will restart it in a clean state. This eliminates:
- Corrupted state from partial recovery
- Error-handling code that is itself buggy
- The need to predict every possible failure mode

### Retry Patterns

Retry is **not done in application code** — it's done by the supervisor:

```erlang
%% Supervisor child spec: restart up to 3 times in 5 seconds
init([]) ->
    {ok, {{one_for_one, 3, 5}, [
        #{id => worker, start => {my_worker, start_link, []},
          restart => permanent, type => worker}
    ]}}.
```

For explicit retry of operations (e.g., HTTP calls), Erlang developers write tail-recursive retry loops:
```erlang
fetch_with_retry(Url, 0) -> {error, max_retries};
fetch_with_retry(Url, N) ->
    case httpc:request(Url) of
        {ok, Result} -> {ok, Result};
        {error, _}   -> timer:sleep(1000), fetch_with_retry(Url, N - 1)
    end.
```

## OTP Behaviours

OTP provides generic process patterns:

| Behaviour | Purpose |
|---|---|
| `gen_server` | Stateful server process (request/reply, cast, info) |
| `gen_statem` | Finite state machine with complex state transitions |
| `supervisor` | Monitors and restarts child processes |
| `application` | Top-level component with start/stop lifecycle |
| `gen_event` | Event manager with swappable handlers |

## Ecosystem

- **Rebar3** — build tool (compile, test, release, dependency management)
- **Hex.pm** — package registry (shared with Elixir)
- **Cowboy** (v2.14) — HTTP/1.1 + HTTP/2 + WebSocket server. HTTP/3 in progress via Quicer integration.
- **Gun** (v2.2) — HTTP/1.1, HTTP/2, WebSocket **client**. Process-based connection management.
- **Ranch** — TCP connection pool (used by Cowboy)
- **Quicer** (v0.2.15) — QUIC transport NIF (MsQuic). Production-proven at EMQX.
- **grpcbox** — gRPC server/client (unary, streaming, bidirectional) built on chatterbox (HTTP/2)
- **EUnit** — lightweight unit testing
- **Common Test** — integration/system testing with suite management
- **Dialyzer** — static type analysis via success typing
- **PropEr** — property-based testing

## Network & Protocol Support

| Protocol | Library | Notes |
|---|---|---|
| HTTP/1.1 | Cowboy (server), Gun (client), httpc (OTP) | Mature |
| HTTP/2 | Cowboy 2.x (server), Gun (client) | Full h2 spec compliance |
| HTTP/3 | Quicer + Cowboy (in progress) | QUIC transport ready, HTTP/3 framing WIP |
| WebSocket | Cowboy `cowboy_websocket` (server), Gun (client) | First-class handler behaviour |
| gRPC | grpcbox | All RPC types, health checks, interceptors |
| SSE | Cowboy `cowboy_req:stream_reply/2` + `stream_body/3` | Manual event formatting |
| Unix sockets | `gen_tcp` with `{local, Path}` (OTP 19+) | Also works for Erlang distribution |

## Inter-Process Communication

All BEAM IPC primitives are Erlang-native:

- `!` (send operator) / `receive` — async message passing to any PID (local or remote node)
- `gen_server:call/2,3` — sync request-reply with timeout (default 5s)
- `gen_server:cast/2` — async fire-and-forget
- `:pg` (OTP 25+) — cluster-wide process groups (replaced `:pg2`)
- `:global` — cluster-wide singleton name registration
- ETS — shared read-optimized in-memory tables across processes on a single node
- `erlang:monitor/2` — unidirectional process death notification
- `erlang:link/1` — bidirectional death propagation

## TTY & Terminal Support

- `io:columns/0`, `io:rows/0` — detect terminal size
- `io:setopts([binary])` — binary mode for raw input
- **OTP 28 raw mode** — `erl -noshell` now supports raw/cooked sub-modes for keystroke-at-a-time input without C NIFs
- ANSI escape sequences must be emitted manually (no stdlib helper like Elixir's `IO.ANSI`)
- No terminfo library — ANSI/VT100 is assumed

## Container Awareness

- **OTP 23+**: Automatically detects cgroup CPU quotas, sets scheduler count accordingly
- `memsup` (from `os_mon`): Reports system memory (may show host memory in containers)
- Manual cgroup reading: `file:read_file("/sys/fs/cgroup/memory.max")` for container memory limits
- `+S` flag: Manual scheduler count override for fine-tuning in containers

## Special Features

- **Bit syntax** — parse binary protocols (TCP headers, MQTT frames, custom wire formats) with declarative pattern matching. No other mainstream language matches this.
- **`receive` with selective matching** — a process can selectively match messages in its mailbox, deferring messages that don't match the current pattern. This enables complex protocol state machines.
- **Distributed Erlang** — transparent RPC across nodes with the same syntax as local calls.
- **`dbg` / `recon_trace`** — production-safe tracing: attach to a running node and observe function calls, message passing, and process state without redeploying.
- **Mnesia** — distributed database built into OTP. Controversial (CAP trade-offs) but unique: a real database that lives inside your runtime and participates in your supervision tree.
- **`sys` module** — introspect any OTP process at runtime: get state, trace calls, suspend/resume, without code changes.

## Binary Distribution & Fat Binary Options

### `rebar3 release` (via relx)
Self-contained directory with compiled `.beam` files + ERTS. `include_erts: true` by default in prod. No Erlang install needed on target. Not a single file.

### Single-binary option: warp-packer
[warp-packer](https://github.com/dgiagio/warp) compresses a rebar3 release directory into one self-extracting executable:
1. `rebar3 release`
2. `warp-packer -a linux-x64 -i _build/default/rel/myapp -e bin/myapp -o myapp`

Can be automated via rebar3 post-hooks. Binary sizes similar to Burrito (~15-20 MB). Works best on Linux.

### escript (`rebar3 escriptize`)
Single file, but **requires Erlang on target**. No OTP supervision trees, no hot code reload, no SASL release handling. Best for CLI tools targeting developer machines.

### Other approaches
- Wrap via an Elixir project using **Burrito** (Zig-based, cross-platform, production-grade).
- **Docker**: Alpine multi-stage with rebar3 release for minimal images.
- **Gleam**: `gleescript` (v1.5) bundles Gleam-on-BEAM into an escript. Still needs Erlang on target. For true single binary: gleescript + Burrito wrapper.

## WASM Support

- **AtomVM** (v0.6.6) — tiny BEAM VM in C. Compiles to WASM, can run Erlang bytecode in the browser. Subset of OTP. Also targets ESP32, STM32, RPi Pico.
- No native Erlang-to-WASM compiler exists.

## Desktop Application Development

- **wx** (ships with OTP, v2.5.4) — Erlang binding for wxWidgets. Full access to windows, dialogs, menus, events, wxWebView. Observer is built with it. The only maintained GUI option for Erlang.
- **gs** (removed OTP 20, 2017) — the old Tcl/Tk-based GUI system. Replaced by wx.
- **etk** (ancient) — direct Tk 4.2 binding, predated gs, long removed.

### Tcl/Tk Integration

Erlang's original GUI story was Tcl/Tk via **gs** and **etk**, both now removed. Current options:
- **etclface** — Tcl C extension using `erl_interface` to join a Distributed Erlang cluster from Tcl/Tk apps
- **portcl** — Erlang port to `wish`/`tclsh`; drive Tk GUIs via stdin/stdout
- Neither is on Hex.pm. This is a niche approach today — wx is the practical choice.

## Notable Software Built with Erlang

| Project | Scale/Description |
|---|---|
| **WhatsApp** | 2B+ users, ~100B messages/day, ~50 engineers. Erlang's defining success story. |
| **Ericsson telecom** | 5G/4G/3G infrastructure. AXD301 switch: 99.9999999% uptime. |
| **Cisco** | ~2M devices/year shipping Erlang; ~90% of internet traffic passes through Erlang routers |
| **RabbitMQ** | Most widely deployed open-source message broker (AMQP, MQTT, STOMP) |
| **EMQX** | Most scalable MQTT broker: 100M concurrent IoT connections |
| **ejabberd** | Powers Nintendo Switch push notifications: 10M connections, 2B messages/day |
| **CouchDB** | Apache distributed document database with HTTP/JSON API |
| **Riak** | Distributed key-value database (Amazon Dynamo-inspired) |
| **Klarna** | Europe's largest fintech; core payment processing backend |
| **Goldman Sachs** | High-frequency trading, real-time market data processing |
| **Amazon SimpleDB** | AWS distributed database service |
| **VerneMQ** | High-performance distributed MQTT broker |
| **MongooseIM** | Enterprise XMPP server (fork of ejabberd) by Erlang Solutions |
| **Wings 3D** | Open-source 3D subdivision modeler |

## Strengths

- **30+ years battle-tested** — powers WhatsApp, RabbitMQ, CouchDB, telecom infrastructure
- **9-nines uptime** — Ericsson's AXD301 switch achieved 99.9999999% availability
- **Hot code reloading** — update running systems without downtime
- **Distributed by default** — clustering built into the VM
- **Small, stable language** — hasn't changed dramatically; code from 2005 still compiles
- **Binary protocol mastery** — bit syntax makes Erlang unmatched for network protocol work

## Weaknesses

- **Syntax** — Prolog heritage is unfamiliar to most developers; commas/semicolons/periods are error-prone
- **String handling** — strings are lists of integers by default; binaries are better but verbose
- **Smaller community** — most new BEAM developers choose Elixir
- **Tooling** — IDE support and developer experience lag behind modern languages
- **No macros** — metaprogramming limited to parse transforms (complex and rarely used)
- **No static types** — Dialyzer is good but optional and incomplete; runtime crashes are the primary type error signal
- **Map/record ergonomics** — maps lack compile-time field checking; records are compile-time but awkward
- **Desktop GUI** — wx is functional but dated; no modern native UI framework

## When to Choose Erlang Over Elixir

- Maintaining existing Erlang codebases
- Embedded/IoT systems where minimal runtime matters
- Teams with existing Erlang expertise
- Libraries that need to work across all BEAM languages without Elixir dependency
- Binary protocol implementations (Erlang's bit syntax is more natural without Elixir's macro overhead)
