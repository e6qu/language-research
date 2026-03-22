# Lua

Lua is a lightweight, embeddable scripting language created at PUC-Rio (Brazil) in 1993. Current version: 5.5.0 (December 2025). Its defining trait is a ~200 KB runtime with zero dependencies, making it the standard choice for embedding a scripting engine inside a host application.

## Language Features

- **Tables as everything** — arrays, dictionaries, objects, modules, namespaces are all tables
- **Metatables** — operator overloading (`__add`, `__index`, `__tostring`, `__gc`), prototype-based OOP, proxies, DSLs
- **First-class functions** — closures, upvalues, tail calls
- **Coroutines** — first-class, asymmetric, cooperative. `coroutine.create/resume/yield`
- **Minimal syntax** — ~22 keywords, block-terminated with `end`, no semicolons required
- **Environments** — each function can have its own global table (sandboxing)
- **Multiple return values** — `return a, b, c` is idiomatic
- **Varargs** — `function f(...)` with `select('#', ...)` for count

**Lua 5.5 new features**: `global` keyword (opt-in global declarations for typo checking), ~60% more compact arrays, incremental major GC, external strings, `table.create`.

### Key Dialects

- **LuaJIT 2.1** — trace-based JIT compiler. Near-C performance for numerical/loop-heavy code. FFI for calling C directly. Still on Lua 5.1 semantics.
- **Luau** (Roblox) — Lua 5.1 derivative with gradual type system, native codegen, sandbox-safe. Open source.

## Type System

Lua is **dynamically typed** — values carry types, variables do not.

**Eight types**: nil, boolean, number (integer + float since 5.3), string, function, table, userdata, thread (coroutine).

**Type checking tools:**
- **Teal** (~2.6k stars) — statically typed dialect compiling to Lua. Generics, union types, interfaces, records. "TypeScript for Lua."
- **Luau** — Roblox's gradual type system. Structural typing, annotations, inference, three strictness modes.
- **LuaLS** (Language Server) — type checking via annotation comments (`---@param`, `---@return`).

**Strengths**: Simplicity, tables-are-everything universality, Teal/Luau add optional safety.
**Weaknesses**: No native static types, no built-in enums/ADTs, easy to pass wrong types silently.

## Error Handling

- **`pcall(f, ...)`** — protected call. Returns `true, results...` or `false, error_message`. Primary error handling mechanism.
- **`xpcall(f, handler, ...)`** — protected call with custom error handler (can capture `debug.traceback()`).
- **`error(message, level)`** — raises an error. Errors can be any value (string, table, etc.).
- **Return convention**: `nil, err_msg` for expected failures. `error()` for programming bugs.
- **No exceptions** — pcall/xpcall is all you get. No try/catch syntax.

```lua
local ok, result = pcall(function()
    return dangerous_operation()
end)
if not ok then
    print("Error: " .. result)
end
```

### Retry Pattern
```lua
local function retry(fn, max, delay)
    for i = 1, max do
        local ok, result = pcall(fn)
        if ok then return result end
        if i < max then os.execute("sleep " .. delay) end
    end
    error("Max retries exceeded")
end
```

## Concurrency

- **Coroutines** — cooperative, single-threaded. Only one coroutine runs at a time. No preemption.
- **No built-in parallelism** — must rely on host (C) for OS threads.
- **Async libraries**:
  - **cqueues** — coroutine scheduling via epoll/kqueue (used by lua-http)
  - **Luvit** — Node.js-style async I/O on libuv
  - **OpenResty** — Nginx's event loop + LuaJIT coroutines. Tens of thousands of concurrent connections.
  - **Copas** — coroutine-based async TCP/HTTP dispatcher

**vs BEAM**: Lua coroutines are cooperative and single-threaded. BEAM has preemptive, massively parallel lightweight processes (millions). No equivalent to OTP supervisors, distributed messaging, or hot code reload.

## Network & Protocol Support

| Protocol | Library | Notes |
|---|---|---|
| HTTP/1.1 | lua-http, lua-resty-http | lua-http is the primary full-featured option |
| HTTP/2 | lua-http | Full HTTP/2 support |
| HTTP/3 | None | Would need FFI to C library |
| WebSocket | lua-http, lua-websockets | RFC 6455 compliant |
| gRPC | None native | Would need FFI bindings |
| Unix sockets | LuaSocket (luasocket) | Via socket.unix |

## Web Servers & Frameworks

- **OpenResty** (~11.7k stars for lua-nginx-module) — Nginx + LuaJIT. Powers Cloudflare, Kong. Production-grade.
- **Kong** (~42.5k stars) — API gateway on OpenResty. Most-starred Lua project.
- **Lapis** (v1.17, Nov 2025) — full web framework on OpenResty. Routes, templates, ORM, migrations.
- **Turbo.lua** — async web framework inspired by Tornado.

## CLI & Binary Distribution

| Method | Size | Self-Contained? | Notes |
|---|---|---|---|
| **Luapak** | 200 KB - 1 MB | Yes (static) | Bundles interpreter + modules into one exe |
| **Luastatic** | Similar | Yes | Generates C source wrapping bytecode |
| **LuaJIT static** | ~300 KB | Yes (with musl) | Smallest option |
| **dyne/luabinaries** | ~100-500 KB (upx) | Yes | Pre-built, musl, upx-compressed |

Lua wins decisively on binary size vs BEAM (200 KB - 1 MB vs 15-42 MB).

## TUI & Terminal Support

- **LTUI** (v2.2) — cross-platform terminal UI based on curses. From the xmake project.
- **lua-curses** — ncurses bindings (in Debian repos).
- **lua-nocurses** — VT100 escape sequences, no ncurses dependency.

## Desktop GUI

- **IUP** — native controls (Win32, GTK, Motif). Developed at PUC-Rio alongside Lua.
- **wxLua** — wxWidgets bindings. Native look-and-feel on all platforms.
- **LOVE 2D** (~7.9k stars) — 2D game framework. Cross-platform.

## WASM Support

- **Wasmoon** — Lua 5.4 VM compiled to WASM. Works in browser, Node.js, Deno. Active development (v2.0 in progress).
- **Fengari** — Lua VM rewritten in JavaScript (slower).

## Container Awareness

Nothing built-in. No cgroup awareness. LuaJIT has a fixed 1-2 GB memory limit on 64-bit which can conflict with container limits.

## Observability

- **Prometheus**: `nginx-lua-prometheus` for OpenResty. No standalone client.
- **Structured logging**: LuaLogging + manual JSON via dkjson/cjson. No equivalent to LoggerJSON.
- **OpenAPI**: Client generation via OpenAPI Generator. Validation via `lua-oasvalidator`. No server-side spec generation.
- **Health checks**: Manual HTTP endpoints.

## Integration with BEAM

- **Luerl** (~1.1k stars, v1.5.1) — Lua 5.3 implemented in **pure Erlang/OTP**. Created by Robert Virding (Erlang co-creator). Runs Lua scripts sandboxed on BEAM. Call Erlang from Lua and vice versa. No NIFs, no ports.
- **`lua` Elixir library** — ergonomic Elixir wrapper around Luerl.
- **Use case**: Embed user-provided Lua scripts in Elixir/Erlang apps (game logic, config, rules engines).

## Embeddability — Lua's Defining Strength

~150-200 KB VM. Clean ANSI C. Simple stack-based C API. Zero external dependencies.

This is Lua's killer feature: it fits inside anything. Game engines, editors, network tools, embedded devices. BEAM is the opposite — it IS the runtime, not a guest language.

## Performance

- **LuaJIT**: Can rival C for numerical/loop-heavy code. 10-100x faster than BEAM for single-threaded computation.
- **Lua 5.5 interpreter**: 10-30x slower than LuaJIT. Still fast for a bytecode interpreter.
- **vs BEAM**: LuaJIT wins single-threaded. BEAM wins concurrent/distributed/fault-tolerant. Different targets.

## Notable Projects

| Project | Description |
|---|---|
| **Neovim** | Vim fork with Lua plugin ecosystem (~97k stars) |
| **Kong** | Cloud-native API gateway (~42.5k stars) |
| **OpenResty** | Nginx + LuaJIT web platform |
| **Roblox/Luau** | Game platform (billions of plays/month) |
| **Redis** | Lua scripting for server-side logic |
| **World of Warcraft** | UI addon system entirely in Lua |
| **Adobe Lightroom** | Significant Lua codebase |
| **LOVE 2D** | 2D game framework (~7.9k stars) |
| **nmap** | Network scanner with Lua scripting engine |
| **HAProxy** | Load balancer with Lua scripting |
| **Wireshark** | Protocol dissectors in Lua |

## Strengths

- **Embeddability** — 200 KB, zero deps, clean C API. Fits inside anything.
- **LuaJIT performance** — near-C speed for compute-heavy code
- **Tiny binaries** — static Lua executables under 1 MB
- **Simplicity** — ~22 keywords, learnable in a day
- **Metatables** — powerful metaprogramming without macros
- **Battle-tested** — 30+ years, embedded in billions of devices

## Weaknesses

- **No built-in concurrency** — coroutines are cooperative and single-threaded
- **No standard library** — minimal stdlib; everything requires external libraries
- **Fragmented ecosystem** — LuaRocks (~6.3k modules) is small; many libs are vendored
- **LuaJIT stuck on 5.1** — the best runtime doesn't support latest language features
- **No fault tolerance** — no supervisors, no process isolation, no hot code reload
- **No distributed computing** — single-process language
- **Cloud-native gaps** — no mature Prometheus, structured logging, or OpenAPI tools (outside OpenResty)

## When to Choose Lua

- **Embedding a scripting engine** in a C/C++/Rust host application
- **Game scripting** — Roblox, WoW, LOVE 2D
- **Edge computing** — OpenResty/Nginx Lua for request processing at the edge
- **Extremely constrained environments** — IoT, microcontrollers, minimal containers
- **Performance-critical scripting** — LuaJIT when you need near-C speed in a dynamic language
- **User-provided logic** — safe sandboxed execution (Luerl on BEAM, or Lua's environment sandboxing)
