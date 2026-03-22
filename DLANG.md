# D — Practical Systems Programming with High-Level Features

## Overview

D is a systems programming language with C-like syntax, designed by Walter Bright and
Andrei Alexandrescu. First released in 2001, D aims to combine the power of C++ with
the productivity of modern scripting languages. It compiles to native code via three
compiler backends (DMD, LDC/LLVM, GDC/GCC).

- **Current version**: DMD 2.112.0 (January 2026)
- **Paradigm**: Multi-paradigm — imperative, OOP, functional, generic, metaprogramming
- **Typing**: Static, strong, with optional dynamic via `Variant`
- **Compilation**: AOT to native code (DMD, LDC, GDC)
- **Package manager**: DUB (code.dlang.org registry)
- **GC**: Tracing GC by default (can be disabled per-scope or globally)
- **License**: Boost Software License (compiler + stdlib)

### Design Philosophy
D takes the pragmatic middle ground: GC by default for productivity, with escape hatches
to disable it when you need deterministic performance. It offers C++ power (templates,
operator overloading, inline assembly) without C++ complexity (no header files, no
preprocessor, no include-order dependencies, no textual macros).

## GC — Default with Opt-Out

D uses a conservative, stop-the-world garbage collector by default. Unlike Java/Go, D
lets you disable or bypass the GC when needed.

```d
// GC-managed allocation (default)
auto arr = new int[](1000);

// Disable GC for a critical section
import core.memory : GC;
GC.disable();
scope(exit) GC.enable();
// ... performance-critical code, no GC pauses ...

// Manual memory management via C malloc
import core.stdc.stdlib : malloc, free;
auto ptr = cast(int*) malloc(int.sizeof * 1000);
scope(exit) free(ptr);
```

- GC simplifies most application code — no ownership headaches
- `@nogc` function attribute: compiler enforces no GC allocations in annotated functions
- `scope` and `-dip1000` enable stack allocation with escape analysis
- LDC optimizer can often elide GC allocations entirely

## Templates & Metaprogramming

D's template system is arguably its most powerful feature — more capable than C++ templates,
more readable than Rust macros.

### Templates
```d
// Function templates with constraints
T max(T)(T a, T b) if (is(typeof(a < b))) {
    return a > b ? a : b;
}

// Struct templates
struct Stack(T) {
    T[] data;
    void push(T val) { data ~= val; }
    T pop() { return data[$ - 1]; /* ... */ }
}
```

### String Mixins — Compile-Time Code Generation
```d
// Generate code from strings at compile time
mixin(`int x = 42;`);
assert(x == 42);

// Practical: generate struct fields from a list
string generateFields(string[] names) {
    string result;
    foreach (name; names)
        result ~= "int " ~ name ~ ";\n";
    return result;
}

struct Config {
    mixin(generateFields(["width", "height", "depth"]));
    // Generates: int width; int height; int depth;
}
```

### CTFE — Compile-Time Function Execution
```d
// Regular D functions run at compile time when inputs are known
int factorial(int n) {
    return n <= 1 ? 1 : n * factorial(n - 1);
}

// Computed at compile time — zero runtime cost
enum fact10 = factorial(10); // 3628800
static assert(fact10 == 3_628_800);
```

### Template Mixins
```d
// Reusable code injection (like traits in Rust, but more powerful)
mixin template Logging() {
    void log(string msg) {
        import std.stdio : writeln;
        writeln("[", typeof(this).stringof, "] ", msg);
    }
}

struct Server {
    mixin Logging;  // injects log() method
    void start() { log("Starting server"); }
}
```

## Ranges — Lazy Iteration

D's range abstraction replaces C++ iterators with a composable, lazy pipeline model.
Ranges are the foundation of D's `std.algorithm` and `std.range`.

```d
import std.algorithm : filter, map, sum;
import std.range : iota;

// Lazy pipeline — nothing computed until consumed
auto result = iota(1, 1_000_001)        // lazy 1..1000000
    .filter!(n => n % 3 == 0)           // lazy filter
    .map!(n => n * n)                   // lazy map
    .sum;                                // consumed here
```

- **Input ranges**: `front`, `popFront`, `empty` — minimal interface
- **Forward/bidirectional/random-access** ranges for richer capabilities
- `std.algorithm` provides 70+ algorithms working on any range
- No heap allocation for the pipeline itself — ranges are value types
- Comparable to Rust iterators, but predating them by a decade

## UFCS — Uniform Function Call Syntax

Any free function can be called as a method on its first argument.

```d
import std.algorithm : sort, uniq;
import std.array : array;

int[] data = [3, 1, 4, 1, 5, 9, 2, 6, 5];

// These are equivalent:
auto result1 = array(uniq(sort(data)));
auto result2 = data.sort.uniq.array;  // UFCS — reads left-to-right

// Extend any type with "methods" without modifying it
string shout(string s) { return s.toUpper ~ "!"; }
auto msg = "hello".shout;  // "HELLO!"
```

UFCS enables pipeline-style code without needing extension methods or traits. Combined
with ranges, it creates a fluent, readable data-processing style.

## BetterC Mode

`-betterC` produces a D binary that requires only the C runtime — no D runtime, no GC,
no TypeInfo, no module constructors. Suitable for kernel development, embedded systems,
or replacing C code gradually.

```d
// Compile with: ldc2 -betterC main.d
extern(C) int printf(const char* fmt, ...);

extern(C) void main() {
    printf("Hello from betterC\n");
}
```

**What you keep in betterC**: templates, CTFE, ranges, UFCS, `scope(exit)`, slices,
operator overloading, `static foreach`, compile-time introspection.

**What you lose**: GC, exceptions (use `nothrow`), `TypeInfo`, runtime reflection,
associative arrays (use manual alternatives), dynamic arrays (use slices + malloc).

## Error Handling

```d
import std.exception : enforce;

// Exceptions (default mode)
auto file = File("config.toml", "r");  // throws on failure

// enforce — assert-like but throws
auto port = enforce(config.get("port"), "Missing port in config");

// Nothrow style (betterC compatible)
int safeDivide(int a, int b) nothrow {
    if (b == 0) return int.min;  // sentinel
    return a / b;
}

// scope guards — deterministic cleanup
void processFile(string path) {
    auto f = File(path, "r");
    scope(exit) f.close();       // always runs
    scope(failure) log("Failed to process " ~ path);  // on exception only
    scope(success) log("Processed " ~ path);           // on success only
    // ... process ...
}
```

- `scope(exit/success/failure)` — D's answer to RAII, more explicit than destructors
- Exceptions by default, `nothrow` for hot paths and betterC
- `enforce` for assertion-style checks that throw
- `Nullable!T` in std.typecons for optional values

## Concurrency

```d
import std.parallelism : parallel, taskPool;
import std.concurrency : spawn, receive, send;

// Data parallelism — parallel foreach
auto data = iota(0, 1_000_000).array;
foreach (ref x; data.parallel) {
    x = expensiveComputation(x);
}

// Message passing (actor-style)
auto worker = spawn((Tid parent) {
    receive((string msg) {
        parent.send("Processed: " ~ msg);
    });
});
worker.send("hello");
```

- `std.parallelism` — work-stealing thread pool, `parallel` foreach, `task`/`asyncBuf`
- `std.concurrency` — actor-style message passing between threads
- `shared` qualifier for safely sharing data across threads
- `synchronized` blocks and classes
- Fibers (`std.concurrency.Fiber`) for cooperative multitasking

## DUB Package Manager

```bash
dub init myproject          # create new project
dub build                   # build
dub run                     # build + run
dub test                    # run unit tests
dub add vibe-d              # add dependency
```

- `dub.json` or `dub.sdl` for project configuration
- code.dlang.org registry (~2,500 packages)
- Supports DMD, LDC, and GDC backends
- Built-in unit test runner (`unittest` blocks in D source)

## Web & Networking

- **Vibe.d** — async I/O framework, fiber-based concurrency. HTTP/1.1, HTTP/2, WebSockets, TLS
- **Hunt Framework** — full-stack web framework
- **Arsd** — Adam Ruppe's minimal HTTP server, CGI, DOM, etc.
- **std.net.curl** — libcurl bindings in the standard library
- **Mir** — high-performance numerical computing (BLAS/LAPACK wrappers, ndslice)

## Comparison with C++

| Aspect | D | C++ |
|---|---|---|
| **Compilation speed** | Fast (DMD: ~50K lines/sec) | Slow (headers, includes, templates) |
| **Metaprogramming** | CTFE + string mixins (readable) | Template metaprogramming (arcane) |
| **Memory management** | GC default + manual opt-out | Manual (RAII, smart pointers) |
| **Headers** | No header files | Header/source split |
| **Preprocessor** | None (CTFE replaces it) | Textual preprocessor (#define, #include) |
| **Ranges** | Built into stdlib | C++20 ranges (newer, less mature) |
| **ABI** | C ABI compatible | C++ ABI fragile |
| **Ecosystem** | Small (~2,500 packages) | Massive |
| **Build system** | DUB (built-in) | CMake/Make/Meson (external) |

## Comparison with Rust

| Aspect | D | Rust |
|---|---|---|
| **Memory safety** | GC (runtime) | Borrow checker (compile-time) |
| **Learning curve** | Moderate (familiar to C++ devs) | Steep (ownership model) |
| **GC** | Yes (can be disabled) | No |
| **Metaprogramming** | CTFE + mixins (powerful, readable) | Proc macros (separate crate, complex) |
| **Compile times** | Fast (DMD) | Slow |
| **Ecosystem** | Small | Large (crates.io) |
| **C interop** | Excellent (extern(C), betterC) | Good (FFI, bindgen) |
| **C++ interop** | Direct (extern(C++)) | Difficult (cxx crate) |
| **Exceptions** | Yes (+ nothrow option) | No (Result/panic) |
| **Industry adoption** | Niche | Growing rapidly |

## Notable Users

| Organization | Usage |
|---|---|
| **Sociomantic/dunnhumby** | Ad-tech platform, heavy D usage in production |
| **eBay** | Used D for search infrastructure |
| **Facebook** | Used D internally (Andrei Alexandrescu was at FB) |
| **Mercedes-Benz** | Autonomous driving research |
| **Symmetry Investments** | Quantitative finance, major D sponsor |
| **Funkwerk** | Railway scheduling systems |
| **Weka.io** | Distributed file system (D + betterC) |

## Strengths

- **Metaprogramming** — CTFE + string mixins are uniquely powerful and readable
- **Ranges + UFCS** — elegant lazy data processing pipelines
- **GC with escape hatches** — productive by default, performant when needed
- **Fast compilation** — DMD compiles ~50K lines/sec
- **C/C++ interop** — `extern(C)`, `extern(C++)`, and betterC mode
- **Built-in unit tests** — `unittest` blocks alongside code
- **`scope` guards** — deterministic cleanup without RAII complexity

## Weaknesses

- **Small ecosystem** — ~2,500 DUB packages vs 150K+ crates or npm packages
- **Small community** — fewer jobs, fewer tutorials, fewer Stack Overflow answers
- **GC stigma** — systems programmers avoid it; disabling GC is possible but ergonomically rough
- **Three compilers** — DMD/LDC/GDC can have subtle differences
- **Standard library churn** — `std.experimental` features sometimes stall
- **Limited industry adoption** — overshadowed by Rust for new systems work
- **Async story** — Vibe.d fibers work but feel dated compared to async/await

## When to Choose D

- **C++ replacement** where you want faster compilation and readable metaprogramming
- **Numerical/scientific computing** — Mir's ndslice is competitive with NumPy
- **Tooling and compilers** — CTFE makes D excellent for writing parsers, code generators
- **Gradual migration from C** — betterC mode lets you adopt D incrementally
- **When GC is acceptable** — web services, batch processing, data pipelines
- **Prototyping systems code** — faster iteration than Rust/C++ with similar performance
