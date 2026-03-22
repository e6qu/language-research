# Zig — Simple, Explicit Systems Programming

## Overview

Zig is a systems programming language designed as a practical replacement for C and C++,
created by Andrew Kelley. First released in 2016, it focuses on explicitness, no hidden
control flow, and no hidden allocations. Zig 0.14.0 shipped March 2025; Zig 1.0 is
targeted for 2026.

- **Current version**: 0.14.0 (March 2025)
- **Paradigm**: Imperative, generic, with compile-time metaprogramming (comptime)
- **Typing**: Static, strong
- **Compilation**: AOT — LLVM backend + self-hosted x86_64 backend (incremental)
- **Package manager**: Built-in (`zig fetch`, `build.zig.zon`)
- **GC**: None — fully manual memory management via explicit allocators
- **License**: MIT

### Design Philosophy
Zig's core principle is "no hidden behavior." Every allocation is explicit, every control
flow path is visible, and the language avoids implicit function calls (no hidden copies,
no hidden destructors, no hidden operator overloads). This makes Zig code auditable and
predictable — critical for systems where you need to know exactly what the machine does.

## Comptime — Compile-Time Metaprogramming

Zig's `comptime` keyword replaces macros, generics, and preprocessors with a single
mechanism: arbitrary Zig code execution at compile time.

```zig
fn Matrix(comptime T: type, comptime rows: usize, comptime cols: usize) type {
    return struct {
        data: [rows][cols]T,

        const Self = @This();

        pub fn identity() Self {
            var result: Self = .{ .data = undefined };
            for (0..rows) |i| {
                for (0..cols) |j| {
                    result.data[i][j] = if (i == j) 1 else 0;
                }
            }
            return result;
        }
    };
}

const Mat4 = Matrix(f32, 4, 4);
const eye = Mat4.identity(); // computed at compile time
```

- Types are first-class values at comptime — you can pass, return, and construct types
- No separate macro language, template syntax, or preprocessor
- Comptime code uses the same language as runtime code
- The compiler evaluates comptime blocks and emits only the result
- Enables generic data structures, compile-time validation, and code generation

## Allocator Model — No Hidden Allocations

Every function that allocates memory takes an `Allocator` parameter explicitly. There is
no global allocator, no implicit `malloc`, no hidden heap usage.

```zig
const std = @import("std");

pub fn main() !void {
    // Choose your allocator explicitly
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit(); // leak detection on deinit in debug mode

    const allocator = gpa.allocator();

    var list = std.ArrayList(u32).init(allocator);
    defer list.deinit();

    try list.append(42);
}
```

**Built-in allocators**:
- `GeneralPurposeAllocator` — debug-friendly, detects leaks, double-free, use-after-free
- `ArenaAllocator` — bulk allocate, free everything at once
- `FixedBufferAllocator` — allocate from a stack buffer (zero heap usage)
- `page_allocator` — direct OS page allocation
- `c_allocator` — wraps libc `malloc`/`free` for C interop

**Why this matters**: Any Zig code can run in environments with no heap (embedded, kernel,
WASM) because allocations are never hidden. The same data structure works with any
allocator — arena for game frames, fixed buffer for embedded, GPA for services.

## Safety Without Sacrificing Performance

Zig provides safety checks in debug/safe modes that are stripped in release builds:

- **Bounds checking** on slices and arrays (debug mode)
- **Integer overflow** detection (debug mode, wrapping available via `+%` operator)
- **Null pointer safety** — optionals (`?T`) instead of raw nullable pointers
- **No undefined behavior by default** — UB is opt-in via `@intToPtr`, `@ptrCast`, etc.
- **Detectable illegal behavior** — the compiler distinguishes between safety-checked UB and truly undefined UB

```zig
// Optionals — no null pointer dereferences
fn find(haystack: []const u8, needle: u8) ?usize {
    for (haystack, 0..) |byte, i| {
        if (byte == needle) return i;
    }
    return null;
}

const index = find("hello", 'l') orelse return error.NotFound;
```

### vs Rust Safety
- Rust enforces safety at compile time (borrow checker) — harder to learn, stronger guarantees
- Zig enforces safety at runtime in debug mode, strips checks in release — simpler model
- Zig trusts the programmer more; Rust trusts the compiler more
- Zig has no lifetimes, no borrow checker — use-after-free is possible in release mode
- Zig's approach: make unsafe things explicit (`@ptrCast`), not implicit

### vs C Safety
- C has pervasive undefined behavior (signed overflow, null deref, buffer overflows)
- Zig eliminates most UB categories — overflow is defined, bounds are checked
- Zig's debug allocator catches memory bugs that C's `malloc` silently corrupts
- Zig still allows manual memory management but makes mistakes detectable

## Cross-Compilation

Zig is a drop-in C/C++ cross-compiler. It ships with target-specific libc headers for
~40 targets and can cross-compile C, C++, and Zig code without installing a cross-toolchain.

```bash
# Build for Linux ARM64 from any host
zig build-exe main.zig -target aarch64-linux-gnu

# Use Zig as a C cross-compiler
zig cc -target x86_64-windows-gnu hello.c -o hello.exe

# Cross-compile a C project with its Makefile
CC="zig cc -target riscv64-linux-musl" make
```

- Targets ~40+ OS/arch combinations out of the box
- Ships libc headers — no separate SDK needed for most targets
- Can replace GCC/Clang as the C compiler in existing build systems
- No libc required — can build freestanding binaries for bare metal / kernels
- Hermetic builds — same Zig version produces identical output on any host

## WASM Target

Zig has first-class WebAssembly support. All standard library data structures work
with WASM because they accept allocators (WASM has no `mmap`/`brk`).

```bash
zig build-exe -target wasm32-wasi main.zig
# or freestanding (no WASI, browser-only)
zig build-lib -target wasm32-freestanding lib.zig
```

- `wasm32-wasi` — WASI runtime target (Wasmtime, Wasmer)
- `wasm32-freestanding` — browser/embedded WASM, no OS interface
- The LLVM backend and the new self-hosted backend both support WASM
- Zig's explicit allocator model maps naturally to WASM's linear memory

## Error Handling

Zig uses error unions — similar to Rust's `Result` but integrated into the language:

```zig
const FileError = error{ NotFound, AccessDenied };

fn readConfig(path: []const u8) FileError![]u8 {
    const file = std.fs.cwd().openFile(path, .{}) catch |err| {
        return switch (err) {
            error.FileNotFound => error.NotFound,
            else => error.AccessDenied,
        };
    };
    defer file.close();
    return file.readToEndAlloc(allocator, 1024 * 1024);
}

// Propagate errors with `try` (equivalent to Rust's `?`)
const config = try readConfig("config.toml");
```

- Error unions: `ErrorSet!T` — a value is either `T` or an error
- `try` propagates errors up the call stack
- `catch` handles errors at the call site
- Error return traces in debug mode (like stack traces for error propagation)
- Errors are values, not exceptions — no hidden control flow

## Build System

Zig's build system is written in Zig itself (`build.zig`). No Makefiles, CMake, or
external tools needed.

```zig
// build.zig
const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "myapp",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Link a C library — Zig handles the cross-compilation
    exe.linkSystemLibrary("sqlite3");
    exe.linkLibC();

    b.installArtifact(exe);
}
```

- Can compile C/C++ sources alongside Zig code
- Incremental compilation (self-hosted backend)
- Caching built into the build system
- Dependencies via `build.zig.zon` (URL-based, hash-verified)

## Concurrency

- **Async/await** was removed in 0.14.0 in favor of a redesign (expected post-1.0)
- Current approach: OS threads via `std.Thread`
- `std.Thread.Pool` for thread pool patterns
- Atomic operations via `@atomicLoad`, `@atomicStore`, `@cmpxchg`
- No runtime, no green threads, no hidden scheduler
- io_uring support in the standard library (Linux)

## Notable Projects

| Project | Description |
|---|---|
| **Bun** | JavaScript/TypeScript runtime — 3x faster than Node.js. Written in Zig + C++ |
| **TigerBeetle** | Distributed financial transactions database. 100% Zig |
| **Mach Engine** | Game engine and graphics toolkit. Cross-platform, Zig-native |
| **River** | Wayland compositor for Linux, written in Zig |
| **Ghostty** | GPU-accelerated terminal emulator by Mitchell Hashimoto |
| **Turso/libSQL** | SQLite fork — Zig used for the rewrite components |
| **zls** | Zig Language Server — IDE support |

## Comparison with Rust

| Aspect | Zig | Rust |
|---|---|---|
| **Memory safety** | Runtime checks (debug), manual (release) | Compile-time (borrow checker) |
| **Learning curve** | Moderate — no borrow checker | Steep — ownership model |
| **Metaprogramming** | comptime (same language) | Procedural macros (separate crate) |
| **Allocations** | Explicit allocator parameter | Implicit global allocator |
| **C interop** | Seamless — can compile C directly | Via FFI (`extern "C"`, `bindgen`) |
| **Async** | Removed/redesigning | Mature (tokio, async-std) |
| **Compile times** | Fast (self-hosted backend) | Slow |
| **Ecosystem** | Young, growing | Large, mature (crates.io) |
| **Safety guarantee** | Weaker (no compile-time memory safety) | Stronger (lifetime verification) |
| **Binary size** | Small (no runtime) | Small (no runtime) |

## Comparison with C

| Aspect | Zig | C |
|---|---|---|
| **Undefined behavior** | Minimal, opt-in | Pervasive |
| **Memory safety** | Debug allocator, bounds checks | None |
| **Build system** | Built-in (build.zig) | External (Make, CMake, etc.) |
| **Cross-compilation** | Built-in for ~40 targets | Requires cross-toolchains |
| **Generics** | comptime | Preprocessor macros (unsafe) |
| **Error handling** | Error unions + try | Return codes (easily ignored) |
| **C interop** | `@cImport` reads C headers directly | N/A |
| **Package management** | Built-in (build.zig.zon) | None standard |
| **Strings** | Slices with length | Null-terminated (buffer overflows) |

## Strengths

- **Comptime** — one mechanism replaces macros, generics, and code generation
- **Explicit allocators** — no hidden allocations, works everywhere including WASM/embedded
- **Drop-in C compiler** — cross-compile C/C++ projects with zero setup
- **Cross-compilation** — ~40 targets out of the box, no toolchain installation
- **Small, fast binaries** — no runtime, no GC, optional libc
- **Readable** — no hidden control flow, no operator overloading, no implicit conversions
- **Incremental compilation** — fast edit/compile/debug cycles (self-hosted backend)

## Weaknesses

- **Pre-1.0** — API instability, breaking changes between versions
- **Small ecosystem** — fewer libraries than Rust, C, or C++
- **No compile-time memory safety** — use-after-free possible in release mode
- **Async story incomplete** — removed in 0.14, redesign pending
- **Limited IDE support** — zls works but less mature than rust-analyzer
- **Documentation gaps** — standard library docs are sparse
- **No destructors/RAII** — must use `defer` manually (easy to forget)

## When to Choose Zig

- **Replacing C** in new systems code where you want safety checks + modern tooling
- **Cross-compiling C projects** — use `zig cc` as a drop-in cross-compiler
- **Embedded / bare metal** — no runtime, no libc dependency, explicit memory control
- **WASM modules** — explicit allocators map naturally to linear memory
- **Game engines** — comptime for data-driven architecture, no GC pauses
- **Performance-critical services** — Bun proves Zig can compete at the application level
- **When Rust's borrow checker is too much** — simpler mental model, still safer than C
