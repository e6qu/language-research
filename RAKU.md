# Raku

Raku (formerly Perl 6) is a multi-paradigm programming language from the Perl family, first specified by Larry Wall in 2000 and reaching its first stable release (6.c "Christmas") in December 2015. Current compiler: **Rakudo 2026.02** (Release #190, February 2026) on the **MoarVM** backend. Raku is a language designed from scratch with grammars, gradual typing, built-in concurrency, Unicode-native processing, and junctions — features that no other dynamic language combines in one package.

## Language Features

- **Grammars** — first-class parsing. Define full parsers as grammar classes with rules, tokens, and regex methods. Parse anything from DSLs to programming languages. Raku's killer feature.
- **Gradual typing** — optional type annotations on variables, parameters, and return values. Runtime enforcement always; compile-time checking where possible.
- **Multiple dispatch** — `multi sub`, `multi method`. Dispatch on number, type, and constraints of arguments. Pervasive throughout the language.
- **Junctions** — superposition values. `any(1,2,3) > 0` evaluates to `True`. Auto-threading through functions. Unique to Raku.
- **Unicode native** — identifiers, operators, and string processing use full Unicode. `my $bg = "abc"` is legal. Unicode operators: `(elem)`, `(|)`, `(<=)`, etc.
- **Lazy lists** — sequences computed on demand. `(1, 2, 4 ... Inf)` generates powers of 2 lazily. Infinite lists are first-class.
- **Rationals** — `1/3` is a `Rat` (rational number), not a float. No floating-point surprises for decimal arithmetic.
- **Set operations** — built-in set types with operators: `(elem)`, `(|)` union, `(&)` intersection, `(-)` difference, `(^)` symmetric difference.
- **Concurrency primitives** — promises, channels, supplies, react/whenever blocks built into the language.
- **Sigils** — `$scalar`, `@positional`, `%associative`, `&callable`. Twigils for scope: `$.public`, `$!private`, `$*dynamic`, `$.contextual`.
- **Metaobject Protocol (MOP)** — introspect and modify classes, roles, and types at runtime.

**Raku 2025 achievements**: Unicode upgraded from 15.0 to 17.0, varargs (va_arg) support in NativeCall for C FFI, pseudo-terminal (PTY) support, `Hash.new()` with named arguments, RakuDoc v2.0 specification completed, 1,650 commits across MoarVM/NQP/Rakudo, 58% of commits on RakuAST (new AST-based compiler frontend).

## Type System

Raku has **gradual typing** — the most sophisticated type system of any dynamic language.

**Type annotations in signatures:**
```raku
sub greet(Str $name, Int $times = 1 --> Str) {
    ("Hello, $name!\n" x $times)
}
```

**Subsets with where clauses:**
```raku
subset Positive of Int where * > 0;
subset Email of Str where *.contains('@');

sub send-mail(Email $to, Positive $retries = 3) { ... }
```

**Type checking behavior:**
- Always enforced at runtime (dynamic typing).
- Compile-time errors when the compiler can prove a type mismatch (gradual typing).
- Unconstrained parameters default to `Any` (opt-in typing).

**Built-in type hierarchy**: Mu > Any > Cool > (Str, Int, Rat, Num, Bool, Array, Hash, ...). Role-based composition. Parametric types (`Array[Int]`, `Hash[Str, Int]`).

**Type checking tools:**
- **Rakudo compiler** — performs compile-time type checking where possible.
- **Comma IDE** — IDE with type inference, error detection, and grammar analysis (commercial development discontinued 2024; open-sourced as IntelliJ plugin).

**Strengths**: Optional typing that scales from scripting to large systems, subsets are uniquely powerful, where clauses enable arbitrary constraints, multiple dispatch integrates with types.
**Weaknesses**: Runtime enforcement means some errors only surface at execution, no separate static analysis tool like Dialyzer.

## Error Handling

```raku
# CATCH blocks with typed exception matching
try {
    my $fh = open "nonexistent.txt";
    CATCH {
        when X::IO::DoesNotExist { say "File not found: {.message}" }
        when X::IO                { say "I/O error: {.message}" }
        default                   { say "Unknown error: {.message}" }
    }
}

# Soft failures with fail/Failure
sub parse-int(Str $s --> Int) {
    $s ~~ /^\d+$/ ?? $s.Int !! fail "Not a number: $s"
}
my $result = parse-int("abc");  # Returns a Failure object, doesn't throw
say $result;                     # NOW it throws (sink context)
$result.defined;                 # Marks as handled, won't throw
```

- **`die`** — throws an exception (can be a string or Exception object).
- **`CATCH` blocks** — structured exception handling inside any block. Pattern-match on exception type with `when`.
- **Typed exceptions** — rich exception hierarchy: `X::IO`, `X::Str::Numeric`, `X::TypeCheck`, `X::AdHoc`, etc. Each carries structured data.
- **`fail` / `Failure`** — soft exceptions. Returns a `Failure` wrapper that only throws when used in sink (void) context or when its value is accessed. Checking for `.defined` or `.Bool` marks it as handled. Unique to Raku.
- **`use fatal`** — pragma that makes all `fail` calls throw immediately.
- **`try` blocks** — catch exceptions without explicit CATCH (returns `Nil` on error).
- **`CONTROL` blocks** — handle control flow exceptions (warnings, `proceed`, `succeed`).

### Retry Pattern
```raku
sub retry(Int $max, Duration $delay, &code) {
    for ^$max -> $attempt {
        my $result = try { code() };
        return $result if $result.defined;
        sleep $delay if $attempt < $max - 1;
    }
    die "Max retries exceeded";
}
```

## Concurrency

Raku has **built-in concurrency primitives** — no external libraries needed.

- **Promises** — `start { ... }` creates a Promise (future). `await` blocks until kept/broken. `Promise.in(5).then({ ... })` for delayed execution.
- **Channels** — thread-safe FIFO queues. `my $ch = Channel.new; $ch.send(42); $ch.receive`.
- **Supplies** — async data streams (like Observables). `supply { whenever $source -> $item { emit $item * 2 } }`. Hot and cold supplies.
- **react/whenever** — reactive programming blocks. `react { whenever $supply -> $item { ... } }`. Composable async event handling.
- **hyper/race** — parallel iteration. `@data.hyper(:degree(4), :batch(100)).map(&expensive)`. `hyper` preserves order, `race` does not. Degree defaults to CPU cores - 1.
- **Locks** — `Lock.new` for mutual exclusion when needed (but message-passing preferred).
- **Proc::Async** — async subprocess management with supply-based stdout/stderr.

```raku
# Parallel processing with hyper
my @results = (1..1000).hyper(:degree(8)).map(-> $n { expensive-compute($n) });

# Reactive streams with supply/whenever
react {
    whenever Supply.interval(1) -> $tick {
        say "Tick $tick";
        done if $tick >= 5;
    }
}
```

**vs BEAM**: Raku's concurrency is high-level and ergonomic but runs on OS threads (MoarVM thread pool). No preemptive scheduling of lightweight processes. No supervision trees. No distributed computing. No hot code reload. BEAM handles millions of processes; Raku is limited to thread-pool size. Raku's `supply`/`whenever` is conceptually similar to GenStage/Flow.

## Network & Protocol Support

| Protocol | Library | Notes |
|---|---|---|
| HTTP/1.1 | Cro::HTTP (v0.8.11) | Full-featured, async |
| HTTP/2 | Cro::HTTP | Supported (server and client), ongoing bug fixes |
| HTTP/3 | None | Not available |
| WebSocket | Cro::WebSocket (v0.8.10) | Built on Cro pipeline model |
| TLS | Cro::TLS (v0.8.10) | IO::Socket::Async::SSL |
| gRPC | None | Not available |

Cro is the primary (and essentially only) HTTP framework for Raku. It supports HTTP/2 for both server and client, though the HTTP/2 stack is still being refined (bug fixes ongoing in 2025).

## Web Servers & Frameworks

- **Cro** (v0.8.11, July 2025) — reactive HTTP framework. HTTP/1.1, HTTP/2, WebSocket, TLS. Route-based with type-checked parameters. Template engine (Cro::WebApp v0.10.0). OpenAPI integration. Beta status, targeting 1.0 for production confidence. Community-maintained since January 2025 (Edument stepped back from commercial development).
- **Air** (2025) — new lightweight web framework emerging in the ecosystem.
- **Humming-Bird** — minimal web framework.

## CLI — Raku's Killer Feature

Raku's `MAIN` sub turns function signatures into CLI argument parsers automatically.

```raku
#| A greeting program
sub MAIN(
    Str $name,              #= Person to greet
    Int :$times = 1,        #= Number of repetitions
    Bool :$loud,            #= Use uppercase
) {
    my $msg = "Hello, $name!";
    $msg = $msg.uc if $loud;
    say $msg for ^$times;
}
```

Running with `--help` or wrong arguments auto-generates:
```
Usage:
  greeting.raku <name> [--times=<Int>] [--loud]

  A greeting program

    <name>          Person to greet
    --times=<Int>   Number of repetitions [default: 1]
    --loud          Use uppercase
```

- **Multi MAIN** — multiple dispatch on `MAIN` creates subcommand-style CLIs automatically.
- **Hidden candidates** — `is hidden-from-USAGE` trait excludes specific MAIN variants.
- **Type coercion** — arguments are automatically coerced to signature types.
- **No libraries needed** — this is a language feature, not a module.

## TUI & Terminal Support

- **Terminal::ANSIColor** — ANSI color/attribute output. Community-maintained (updated December 2025).
- **Terminal::Widgets** — TUI widget toolkit with Anolis integration. Recent PTY support (Rakudo 2025.12).
- **Anolis** (2025) — terminal emulator module. New in the ecosystem.
- **MUGS::UI::TUI** — fullscreen terminal UI for the MUGS game framework.
- **Terminal::Print** — low-level terminal grid manipulation.

## Fat Binary Distribution

**Raku cannot produce standalone executables.** This is a notable limitation.

| Method | Notes |
|---|---|
| **App::InstallerMaker::WiX** | Creates Windows installer bundling compiler + script |
| **Native packages** | .deb, .rpm available for major distros |
| **Relocatable tar.gz** | Rakudo binary distribution for Linux |
| **Docker images** | Containerized deployment |

The lack of fat binary support is one of Raku's most significant practical gaps compared to Perl (PAR::Packer), Lua (Luapak), Tcl (Starpacks), or BEAM (mix release).

## Desktop GUI

- **GTK::Simple** — GTK3 bindings via NativeCall. Basic widget set. Functional but incomplete.
- **Gnome::Gtk3** — more comprehensive GTK3 bindings. Actively maintained.
- **GtkLayerShell** — Wayland layer shell integration.
- **Tk** — work-in-progress bindings. Not mature.

Limited compared to Perl (Tk, Wx, Prima, GTK) or Tcl (native Tk).

## WASM Support

- **Wasm::Emitter** — emit WebAssembly binary format from Raku. Can generate WASI programs. Community module.
- No compilation of Raku itself to WASM. MoarVM is a complex C runtime not easily compiled to WASM.

## Container Awareness

Nothing built-in. No cgroup awareness. Same situation as Perl, Lua, and Tcl — must read `/proc/self/cgroup` manually.

## Observability

### Structured Logging
- **Log::Async** — thread-safe asynchronous logging using supplies. Trace through fatal levels. Colorized output. The primary logging module.
- **Log::Timeline** — event and task logging for async operations. File I/O, threads, sockets, processes.
- No JSON structured logging library equivalent to LoggerJSON or Log4perl::Layout::JSON.

### Prometheus
- **Prometheus::Client** — counters, gauges, summaries, histograms, info, state-set metrics. `is timed` and `is tracked-in-progress` traits for automatic instrumentation. Registry for gathering metrics.

### OpenAPI
- **Cro::OpenAPI::RoutesFromDefinition** — implement API from OpenAPI spec. Request/response validation against schema. Built into Cro.
- **OpenAPI::Schema::Validate** — validate data against OpenAPI schemas.

### Health Checks
Manual HTTP endpoints in Cro. No dedicated framework.

## Integration with BEAM

No bridge exists between Raku and the BEAM. No equivalent to Luerl (Lua), etclface (Tcl), or Rustler (Rust).

**Inline::Perl5** allows Raku to embed a Perl 5 interpreter and call CPAN modules, but this is Raku-to-Perl interop, not BEAM integration.

## Special Features

- **Grammars** — define parsers as classes. Rules, tokens, regex methods. Action classes for AST construction. Nothing comparable in any other dynamic language. Parse JSON, HTML, programming languages, protocols — all in pure Raku.
```raku
grammar CSV {
    token TOP     { <line>+ % \n }
    token line    { <field>+ % ',' }
    token field   { <quoted> | <unquoted> }
    token quoted  { '"' <( <-["]>* )> '"' }
    token unquoted { <-[,\n]>* }
}
my $parsed = CSV.parse($csv-text);
```
- **Junctions** — `any`, `all`, `one`, `none`. Auto-threading through functions. `if $x == any(1, 3, 5) { ... }`. No other language has this.
- **Lazy lists / sequences** — `(1, 1, *+* ... Inf)` generates Fibonacci lazily. `gather/take` for lazy generators.
- **Rationals** — `Rat` type for exact decimal arithmetic. `1/3 + 1/3 + 1/3 == 1` is `True`. Degrades to `Num` (float) only when denominator exceeds 2^64.
- **Unicode operators** — `(elem)`, `(cont)`, `(|)`, `(&)`, `(+)`, `(-)`, `(==)` for set operations. `div`, `mod`, `gcd`, `lcm` as infix operators. Unicode math symbols as alternatives.
- **Multiple dispatch** — central to the language. Functions, methods, operators all dispatch on argument type/count/constraints.
- **Hyperoperators** — `@a >>+<< @b` applies `+` element-wise. `@a>>.method` calls method on each element. Works on any operator.
- **NativeCall** — FFI for calling C libraries directly from Raku. No XS compilation step.
- **Subsets** — define named constrained types: `subset Even of Int where * %% 2`. Use in signatures, dispatch, and variable declarations.
- **Phasers** — `BEGIN`, `CHECK`, `INIT`, `END`, `ENTER`, `LEAVE`, `KEEP`, `UNDO`, `PRE`, `POST`, `FIRST`, `NEXT`, `LAST`, `QUIT`, `CLOSE`, `COMPOSE`. Fine-grained lifecycle hooks.

## Performance

- **MoarVM** — register-based bytecode VM. JIT compiler (limited scope). Specializer for hot-path optimization.
- **Startup time** — noticeably slower than Perl 5 (~100-300ms for a simple script). Significant improvement over early Rakudo but still a weakness.
- **Runtime performance** — generally 2-10x slower than Perl 5 for single-threaded work. Competitive for concurrent workloads.
- **RakuAST** — new compiler frontend (58% of 2025 development effort). Expected to improve compilation speed and enable better optimization.
- **vs BEAM**: MoarVM is a single-process VM. No distributed computing. Thread pool concurrency, not lightweight process concurrency. BEAM's JIT (OTP 24+) is more mature.
- **vs Perl 5**: Slower startup, slower single-threaded, but hyper/race can win for parallel workloads.

## Notable Projects

| Project | Description |
|---|---|
| **Comma IDE** | Raku IDE (IntelliJ-based). Now open-sourced as IntelliJ plugin. |
| **Cro** | Reactive web framework. The main web development option for Raku. |
| **Grammar engine** | Raku's grammar engine itself is a notable achievement in PL design. |
| **RakuDoc v2.0** | Documentation specification and tooling (completed 2025). |
| **Raku Advent Calendar** | Annual community showcase. Active through 2025. |
| **raku.org** | Completely redesigned in 2025 using Raku technologies. |
| **zef** | Package manager. 2,435 modules available. |

The ecosystem is small but growing (508 modules updated/released in 2025, up 38% from 2024).

## Ecosystem

- **zef** — the package manager. Installs from multiple ecosystems.
- **raku.land** — module directory (successor to modules.raku.org).
- **2,435 modules** available (vs CPAN's ~220,000 for Perl 5).
- **13,843 module versions** in the Raku Ecosystem Archive.
- **Inline::Perl5** — escape hatch to CPAN. Use any Perl 5 module from Raku.
- **Raku Community Modules** — adoption center for orphaned modules, giving them new maintainers.
- **508 modules** updated or first released in 2025 (38% increase over 2024).

## Strengths

- **Grammars** — the most powerful parsing facility in any programming language
- **Gradual typing** — optional types with subsets and where clauses. Scales from scripts to large systems.
- **Built-in concurrency** — promises, channels, supplies, react/whenever. No library needed.
- **CLI from signatures** — `MAIN` sub auto-generates usage messages and argument parsing. Best CLI story of any language.
- **Unicode native** — full Unicode support in identifiers, operators, and string processing
- **Junctions** — unique quantum-superposition-style logic
- **Rational arithmetic** — exact decimal math by default
- **Multiple dispatch** — central to language design, not bolted on
- **Expressiveness** — can be extremely concise for the right problems

## Weaknesses

- **Small ecosystem** — 2,435 modules vs 220,000 (CPAN), vs 500,000+ (npm). Inline::Perl5 helps but adds overhead.
- **Performance** — slower startup and runtime than Perl 5. MoarVM JIT is limited.
- **No standalone executables** — cannot produce fat binaries. Major deployment limitation.
- **Community size** — small core developer team. Bus factor concerns.
- **Learning curve** — enormous language surface area. Grammars, junctions, phasers, subsets, hyper operators, Unicode operators — overwhelming for newcomers.
- **Maturity** — Cro is still beta. Many modules are less battle-tested than CPAN equivalents.
- **No distributed computing** — single-node only. No equivalent to BEAM distribution.
- **Cloud-native gaps** — structured logging and Prometheus exist but are basic. No mature monitoring stack.

## When to Choose Raku

- **Parsing / language processing** — grammars are unmatched for DSLs, protocols, data formats
- **CLI tools** — MAIN sub signatures make CLI development trivially easy
- **Data transformation** — lazy lists, junctions, hyper operators, rationals for data pipelines
- **Prototyping with types** — gradual typing lets you start dynamic and add types incrementally
- **Unicode-heavy text processing** — native Unicode support surpasses all other languages compared here
- **Learning/exploration** — Raku is a fascinating language design. Good for expanding programming horizons.

## Comparison: Raku vs Perl vs BEAM

| Dimension | Raku | Perl 5 | BEAM (Elixir/Erlang) |
|---|---|---|---|
| **Killer feature** | Grammars + gradual typing | CPAN + regex + one-liners | Fault tolerance + concurrency |
| **Type system** | Gradual (best of dynamic langs) | Dynamic only | Dynamic + Dialyzer specs |
| **Concurrency** | Built-in (promises, supplies) | Fragmented (fork, IO::Async, MCE) | Preemptive processes (millions) |
| **Ecosystem** | ~2,435 modules | ~220,000 modules | ~17,000 packages (Hex) |
| **Fat binary** | **Not possible** | PAR::Packer (5-30 MB) | mix release (15-42 MB) |
| **CLI** | **MAIN signatures (best)** | Getopt::Long | OptionParser / escript |
| **Web** | Cro (beta) | Mojolicious (mature) | Phoenix (production-grade) |
| **Parsing** | **Grammars (best)** | Regex (excellent) | NimbleParsec / yecc |
| **Community** | Small, growing | Declining but large | Growing |
| **WASM** | Wasm::Emitter (basic) | WebPerl (stalled) | AtomVM |
