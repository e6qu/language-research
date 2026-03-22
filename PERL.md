# Perl

Perl is a high-level, general-purpose, dynamic programming language created by Larry Wall in 1987. Current version: **5.42.1** (stable, July 2025). Development branch: 5.43.x (leading to 5.44.0). Perl is renowned for its text processing power, CPAN ecosystem (~220k modules), and the philosophy "There's More Than One Way To Do It" (TMTOWTDI).

## Language Features

- **Regular expressions** — first-class, deeply integrated into the language. Named captures, lookahead/lookbehind, embedded code, recursive patterns.
- **Context sensitivity** — scalar vs list context. Operators and functions behave differently based on context.
- **Sigils** — `$scalar`, `@array`, `%hash`, `&sub`, `*glob`. Visual type markers.
- **References** — scalars pointing to any data structure. Enable complex nested data.
- **One-liners** — `perl -ne`, `-pe`, `-lane`. Unmatched for command-line text processing.
- **CPAN** — ~220,000 modules, ~43,500 distributions, ~14,500 contributors. The largest language-specific module repository in the world.
- **Moose/Moo OOP** — modern object systems with type constraints, roles, meta-protocol. Moo is the lightweight alternative.
- **Corinna (native OOP)** — `use feature 'class'` (experimental since 5.38, evolving through 5.42). Native `class`, `field`, `method`, `ADJUST` keywords.

**Perl 5.42 new features** (July 2025): `any`/`all` short-circuit list operators (experimental), `:writer` attribute for class fields, `my method` lexical methods, `->&` private method invocation, `source::encoding` pragma, `^^=` XOR assignment, Unicode 16.0, significant performance optimizations. ~280,000 lines changed by 65 contributors.

**Perl 5.40 highlights** (June 2024): `try/catch` no longer experimental (without `finally`), `builtin::true`/`false` stable, `__CLASS__` keyword (experimental), `use v5.40` bundle.

## Type System

Perl is **dynamically typed** — variables have sigils indicating structure ($, @, %), but values carry no enforced types at the language level.

**Runtime type coercion**: Perl freely converts between strings, numbers, and booleans based on context. `"42" + 8` yields `50`. This is a feature, not a bug — but also a source of subtle errors.

**Type checking tools:**
- **Moose type system** — `has 'name' => (is => 'ro', isa => 'Str')`. Rich type hierarchy: Any, Item, Bool, Str, Num, Int, ArrayRef[Str], HashRef, etc. Runtime enforcement.
- **Moo + Type::Tiny** — lightweight type constraints via Types::Standard. Same syntax as Moose, 10x startup speedup.
- **Corinna/class** — field declarations with `:param`, `:reader`, `:writer`. No built-in type constraints yet (planned).
- **Params::Validate / Type::Params** — validate function arguments at runtime.

**Strengths**: Extreme flexibility, context-sensitive coercion is powerful for text processing, Moose/Type::Tiny provide optional rigor.
**Weaknesses**: No compile-time type checking, no gradual typing, no static analysis comparable to Dialyzer or mypy.

## Error Handling

```perl
# Modern: try/catch (stable since 5.40, without finally)
use v5.40;
try {
    dangerous_operation();
}
catch ($e) {
    warn "Caught: $e";
}

# Traditional: eval/die
eval {
    die "something went wrong";
};
if ($@) {
    warn "Error: $@";
}

# Try::Tiny (CPAN, most popular pre-5.34 solution)
use Try::Tiny;
try {
    risky();
} catch {
    warn "Caught: $_";
} finally {
    cleanup();
};
```

- **`die`/`eval`** — core error mechanism. `die` throws, `eval {}` catches. `$@` holds the error. Gotcha: `$@` can be clobbered between `eval` and the check.
- **`try/catch`** — native since 5.34, stable (non-experimental) since 5.40 without `finally`. `finally` still experimental.
- **Syntax::Keyword::Try** — CPAN module providing `try/catch/finally`. Faster than Try::Tiny, native-like syntax. Basis for core `try/catch`.
- **Try::Tiny** — the community standard for years. Correct `$@` handling. Slower than alternatives (closure overhead).
- **Exception objects** — `die` can throw any reference. `die MyException->new(...)`. No built-in exception hierarchy.

### Retry Pattern
```perl
sub retry {
    my ($max, $delay, $code) = @_;
    for my $attempt (1 .. $max) {
        my $result = eval { $code->() };
        return $result unless $@;
        sleep $delay if $attempt < $max;
    }
    die "Max retries exceeded: $@";
}
```

## Concurrency

- **`fork()`** — Unix process forking. Copy-on-write. The traditional and most reliable Perl concurrency mechanism.
- **`ithreads`** — interpreter threads. Each thread clones the entire interpreter. Heavy (~2-10 MB per thread). Many CPAN modules are not thread-safe. Not recommended for new code.
- **IO::Async** (v0.804, April 2025) — event loop framework. Futures, streams, timers, child processes. Built on epoll/kqueue. Paul Evans (core Perl developer).
- **AnyEvent** — universal event loop API. Compatible with multiple backends (EV, Event, IO::Async). Lightweight.
- **Coro** (v6.512) — cooperative coroutines. Lightweight green threads sharing the same interpreter. Combined with AnyEvent for async I/O.
- **MCE** (v1.902) — Many-Core Engine. True parallelism via fork. Bank-queuing model. MCE::Shared for IPC. MCE::Channel for communication. Best option for CPU-bound parallel work.
- **Mojolicious event loop** — built-in non-blocking I/O, promises, async/await via `Mojo::Promise`.
- **Thread::Subs** (2025) — new module for basic parallelism with event loop integration (AnyEvent, Mojolicious, Future).

**vs BEAM**: Perl concurrency is fragmented across multiple incompatible approaches. BEAM has one unified model (lightweight processes + message passing + supervisors). Perl's `fork()` creates OS processes (thousands), BEAM handles millions of processes. No equivalent to OTP supervisors or hot code reload.

## Network & Protocol Support

| Protocol | Library | Notes |
|---|---|---|
| HTTP/1.1 | LWP::UserAgent, HTTP::Tiny (core), Mojo::UserAgent | HTTP::Tiny in core since 5.14 |
| HTTP/2 | Protocol::HTTP2, Net::Async::HTTP | Protocol::HTTP2 is a pure-Perl implementation |
| HTTP/3 | None | No known implementation |
| WebSocket | Mojo::UserAgent, AnyEvent::WebSocket::Client, Net::Async::WebSocket | Mojo has built-in WebSocket support |
| gRPC | Grpc::XS | XS bindings to gRPC C library |
| TLS | IO::Socket::SSL, Net::SSLeay | Mature, production-grade |

Mojolicious provides the most complete HTTP client with built-in non-blocking I/O and WebSocket support, but remains HTTP/1.1 only. HTTP/2 requires separate modules.

## Web Servers & Frameworks

- **Mojolicious** (v9.42) — full-featured real-time web framework. Non-blocking I/O, WebSocket, REST, templates, testing. No non-core dependencies. Created by Sebastian Riedel. The most active Perl web framework.
- **Dancer2** — lightweight Sinatra-inspired framework. PSGI/Plack. Good for smaller apps.
- **Catalyst** (v5.9+) — full MVC framework. Mature, production-grade. PSGI/Plack. Powers many large Perl applications.
- **Plack/PSGI** — middleware specification (like Ruby's Rack, Python's WSGI). Foundation for all modern Perl web apps.
- **Kelp** — lightweight, modular, less opinionated than Dancer2.

## CLI

- **Getopt::Long** — core module. Extended option processing. Long/short options, bundling, type coercion. The standard.
- **Getopt::Std** — core, simpler. Single-character options only.
- **App::Cmd** — subcommand framework (like `git`). Declarative.
- **CLI::Osprey** — Moose-based CLI framework with subcommand support.
- **Pod::Usage** — generate usage messages from POD documentation.

```perl
use Getopt::Long;
use Pod::Usage;

GetOptions(
    'name=s'    => \my $name,
    'count=i'   => \my $count,
    'verbose'   => \my $verbose,
    'help'      => sub { pod2usage(1) },
) or pod2usage(2);
```

## TUI & Terminal Support

- **Curses** — ncurses bindings. Full terminal control.
- **Term::ReadKey** (v2.38) — character-mode terminal I/O. ReadMode, non-blocking reads, terminal size.
- **Term::ReadLine::Gnu** — GNU readline bindings. History, completion, editing.
- **Term::ANSIColor** — ANSI color/attribute output.
- **Term::UI** — interactive prompts, menus, selection lists.

## Fat Binary Distribution

| Method | Size | Self-Contained? | Notes |
|---|---|---|---|
| **PAR::Packer (pp)** (v1.064) | 5-30 MB | Yes | Most popular. Bundles interpreter + modules. Active. |
| **staticperl** | ~500 KB - 2 MB | Yes | Statically linked Perl + modules. Much smaller. |
| **App::FatPacker** | Script size | No (needs perl) | Packs dependencies into script. No binary deps. |
| **Perl2Exe** | 5-20 MB | Yes | Commercial. Last update ~2021. |

PAR::Packer (`pp`) is the standard tool. Larger than Lua/Tcl solutions but functional and well-maintained.

## Desktop GUI

- **Tk** (Perl/Tk) — Tk bindings. Cross-platform. The classic Perl GUI. Still works but aging.
- **Wx** (wxPerl) — wxWidgets bindings. Native look-and-feel. Good for complex apps.
- **Prima** — pure Perl GUI toolkit. Cross-platform. Visual Builder. Modern appearance. The most "Perlish" option.
- **Gtk2/Gtk3** — GTK bindings. Good Linux integration. Used by Padre IDE.
- **GUIDeFATE** — design-from-text-editor tool. Supports Wx, Tk, Gtk, Qt, Win32, HTML, WebSocket backends.

## WASM Support

- **WebPerl** — Perl interpreter compiled to WASM via Emscripten. Runs in browser. Port of the actual perl binary, not a translation.
- **Perl Wasm project** — `Wasm` and `Wasm::Wasmtime` modules for importing WASM functions into Perl. Uses wasmtime. **Development stalled** as of August 2025 due to WASI exception handling proposal gaps.
- **zeroperl** (2025) — experimental sandboxed Perl build for WASM. Faces challenges with WASI runtime support.

## Container Awareness

Nothing built-in. No cgroup awareness. Perl apps respect external container memory/CPU limits but cannot detect them programmatically without reading `/proc/self/cgroup` and `/sys/fs/cgroup/` directly. Perl's memory allocator does not auto-tune to container limits.

## Observability

### Structured Logging
- **Log::Any** — universal logging API (like SLF4J). Adapters for any backend. Structured data support since 2017.
- **Log::Log4perl** — Log4j port. Powerful configuration, categories, appenders. `Log::Log4perl::Layout::JSON` for structured JSON output with MDC (Mapped Diagnostic Context).
- **Log::Dispatch** — configurable output destinations. Multiple dispatchers.
- **Log::Contextual** — context-aware structured logging.

### Prometheus
- **Net::Prometheus** (v0.14) — export metrics in Prometheus text exposition format. Counter, Gauge, Histogram, Summary. PSGI integration. PerlCollector and ProcessCollector for system stats.
- **Prometheus exporter framework** — for building dedicated exporters.

### OpenAPI
- **Mojolicious::Plugin::OpenAPI** — generate routes + validation from OpenAPI 2.0/3.0 spec. Server-side.
- **OpenAPI::Client** — auto-generate client methods from OpenAPI spec.
- **JSON::Validator** — JSON Schema / OpenAPI spec validation.

### Health Checks
Manual HTTP endpoints in Mojolicious/Dancer2/Catalyst. No dedicated health check framework.

## Integration with BEAM

- **beam_makeops** — Perl script used internally by the Erlang build system to generate BEAM instruction mappings. Perl is embedded in the Erlang build process itself.
- No runtime bridge between Perl and BEAM exists. No equivalent to Luerl (Lua) or etclface (Tcl).
- **Inline::Perl5** — Raku module that embeds a Perl 5 interpreter. Allows calling CPAN modules from Raku. Not BEAM-related but relevant to Perl interop.

## Special Features

- **CPAN** — ~220,000 modules, ~43,500 distributions. MetaCPAN for search. PAUSE for uploads. The gold standard of language ecosystems for two decades.
- **Regular expressions** — the most powerful regex engine in any mainstream language. Named captures, recursive patterns, embedded code (`(?{...})`), lookahead/lookbehind, Unicode properties.
- **One-liners** — `perl -ne 'print if /pattern/'`. Unmatched for command-line text processing. Compete with awk/sed but far more powerful.
- **Moose/Moo** — modern OOP with roles (traits), type constraints, meta-object protocol, delegation, lazy attributes. Moo for lightweight, Moose for full power.
- **Corinna** — native class system being built into core (experimental). `class`, `field`, `method`, `ADJUST`, `:reader`, `:writer`.
- **DBI** — database interface. Mature, universal. Drivers for every database. The standard for Perl database access.
- **Text::CSV, XML::LibXML, JSON::XS** — battle-tested data format handling.
- **Benchmark** — built-in benchmarking. `Benchmark::cmpthese` for comparing implementations.

## Performance

- **Bytecode interpreted** with some optimizations. No JIT.
- **5.42 optimizations**: copy-on-write constant-folded strings, faster `tr///` for UTF-8, optimized `builtin::indexed()` in foreach, single-pass string reversal, faster integer stringification.
- **XS** — C extension mechanism for hot paths. Many CPAN modules have XS backends (JSON::XS, Cpanel::JSON::XS, Sereal).
- **vs BEAM**: Perl is generally faster for single-threaded string processing. BEAM wins on concurrency, parallelism, and fault tolerance.
- **vs LuaJIT**: LuaJIT is 10-100x faster for numerical work. Perl is competitive for text processing.

## Notable Projects

| Project | Description |
|---|---|
| **CPAN / MetaCPAN** | The ecosystem itself. ~220k modules. |
| **Bugzilla** | Bug tracking system. Used by Mozilla, Red Hat, GNOME, KDE. |
| **Request Tracker (RT)** | Issue/ticket tracking. Powers rt.cpan.org and many enterprises. |
| **Movable Type** | Blog/CMS platform. Pioneered blogging. |
| **cPanel** | Web hosting control panel. Massive Perl codebase. |
| **DuckDuckGo** | Privacy search engine. Backend partially in Perl. |
| **Booking.com** | Major travel platform. One of the largest Perl codebases. |
| **BBC** | Perl used extensively in backend systems. |
| **IMDb** | Originally built in Perl. |
| **Slashdot/Slash** | News/discussion platform. |
| **SpamAssassin** | Email spam filter. |
| **Webmin** | System administration web interface. |

## Strengths

- **CPAN** — 220k modules. "There's a module for that." Unmatched breadth.
- **Text processing** — regex engine, one-liners, format handling. The language was built for this.
- **Maturity** — 37+ years. Battle-tested in production at scale (Booking.com, cPanel, BBC).
- **Backwards compatibility** — code from the 1990s still runs on modern Perl.
- **Mojolicious** — real-time web framework with no non-core deps. Impressive engineering.
- **DBI** — universal database interface with drivers for everything.
- **Moose/Moo** — best-in-class OOP bolt-on system with type constraints and roles.

## Weaknesses

- **Declining community** — PAUSE signups at historical lows (108 in 2025). Active releasers declining since 2014.
- **Reputation** — "write-only language" perception. Sigils, context sensitivity, and TMTOWTDI alienate newcomers.
- **No static types** — no gradual typing, no compile-time checking beyond `use strict`/`use warnings`.
- **Concurrency fragmented** — fork, ithreads, IO::Async, AnyEvent, Coro, MCE are all incompatible approaches.
- **No HTTP/2 in major frameworks** — Mojolicious is still HTTP/1.1 only.
- **No built-in concurrency model** — nothing like BEAM processes, goroutines, or async/await at the language level (Mojo::Promise is library-level).
- **Binary size** — PAR::Packer produces 5-30 MB executables. Larger than Lua/Tcl.

## When to Choose Perl

- **Text processing / data munging** — parsing logs, transforming data, one-liners
- **Legacy system maintenance** — vast existing Perl codebases need maintenance
- **Rapid prototyping** — CPAN has a module for almost anything
- **Bioinformatics** — BioPerl, established tools, existing pipelines
- **System administration** — tradition of sysadmin scripting, Webmin, monitoring
- **Web applications** — Mojolicious for modern async web apps with WebSocket support
