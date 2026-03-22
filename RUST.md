# Rust — Systems Programming Language

## Overview

Rust is a multi-paradigm systems programming language focused on safety, speed, and
concurrency. Developed originally at Mozilla Research (first stable release 2015), it is
now governed by the Rust Foundation. Rust guarantees memory safety without a garbage
collector through its ownership and borrowing system, enforced at compile time.

- **Current stable**: ~1.84 (2025/2026)
- **Paradigm**: Multi-paradigm — imperative, functional, concurrent, generic
- **Typing**: Static, strong, inferred (Hindley-Milner-inspired)
- **Compilation**: Ahead-of-time (AOT) via LLVM to native code
- **Package manager**: Cargo (crates.io registry)
- **Edition system**: 2015, 2018, 2021, 2024 — backwards-compatible evolution

## Type System

### Strengths
- Ownership + borrowing + lifetimes eliminate data races and use-after-free at compile time
- Algebraic data types: `enum` (sum types) + `struct` (product types)
- Pattern matching is exhaustive — compiler enforces all variants handled
- Traits (similar to typeclasses) provide zero-cost abstractions
- Generics with trait bounds — monomorphized at compile time (no runtime cost)
- No null — uses `Option<T>` instead, must be explicitly unwrapped
- `Result<T, E>` for fallible operations — no hidden exceptions
- Lifetime annotations make reference validity explicit
- The `Send` and `Sync` traits enforce thread safety at compile time

### Weaknesses
- Steep learning curve — borrow checker fights are real, especially for beginners
- Lifetime annotations can become verbose in complex data structures
- Self-referential structs are notoriously difficult
- Orphan rule (trait coherence) can be frustrating — cannot implement foreign traits on foreign types
- Compile times are slow compared to Go or C (though incremental compilation helps)
- Async lifetimes and pinning add significant complexity
- Higher-kinded types (HKTs) not yet supported — workarounds exist but are clunky
- No variadic generics (as of 2025)

## Error Handling

Rust uses `Result<T, E>` for recoverable errors and `panic!` for unrecoverable ones.
There are no exceptions.

```rust
use std::fs;
use std::io;

fn read_config(path: &str) -> Result<String, io::Error> {
    fs::read_to_string(path)
}

fn main() {
    match read_config("config.toml") {
        Ok(contents) => println!("{contents}"),
        Err(e) => eprintln!("Failed to read config: {e}"),
    }
}
```

- The `?` operator propagates errors up the call stack concisely
- `anyhow` crate for application-level error handling (dynamic error types)
- `thiserror` crate for library-level error handling (derive macro for custom errors)
- `panic!` unwinds the stack (or aborts) — used for bugs, not expected failures
- `unwrap()` / `expect()` convert `Option`/`Result` to panics — fine in prototypes, bad in production

## Retries

No built-in retry mechanism. Common crate choices:

- **`backon`** — ergonomic retry with backoff strategies
- **`tokio-retry`** — retry logic for async contexts
- **`again`** — simple retry with exponential backoff
- Manual retry loops are also common given Rust's explicit control flow

```rust
use backon::{ExponentialBuilder, Retryable};

async fn fetch_data() -> Result<String, reqwest::Error> {
    reqwest::get("https://api.example.com/data")
        .await?
        .text()
        .await
}

// Retry with exponential backoff
let result = fetch_data
    .retry(ExponentialBuilder::default().with_max_times(3))
    .await;
```

## Concurrency

### Async/Await (Tokio)
Rust's async model is zero-cost — futures are state machines compiled to efficient code.
The language provides `async`/`await` syntax but no built-in runtime.

- **Tokio** — the dominant async runtime (work-stealing, multi-threaded)
- **async-std** — alternative runtime with std-like API
- **smol** — minimal async runtime

```rust
#[tokio::main]
async fn main() {
    let handle = tokio::spawn(async {
        // runs on the Tokio thread pool
        expensive_computation().await
    });
    let result = handle.await.unwrap();
}
```

### OS Threads
- `std::thread::spawn` for OS-level threads
- `std::sync::{Mutex, RwLock, Arc}` for shared state
- `crossbeam` crate for advanced concurrent data structures (channels, deques, epoch-based GC)

### Channels
- `std::sync::mpsc` — multi-producer, single-consumer
- `tokio::sync::mpsc` / `broadcast` / `watch` — async channels
- `flume` — fast, flexible channel library (sync + async)

### Rayon (Data Parallelism)
```rust
use rayon::prelude::*;
let sum: i64 = (0..1_000_000).into_par_iter().sum();
```

### Key Safety Guarantee
The type system prevents data races at compile time. You cannot share mutable state
across threads without synchronization — the compiler enforces this via `Send` and `Sync`.

## Network Protocols

| Protocol    | Crate(s)                                      | Notes                                |
|-------------|-----------------------------------------------|--------------------------------------|
| HTTP/1.1    | `hyper`, `reqwest`                             | hyper is low-level, reqwest is high-level |
| HTTP/2      | `hyper` (built-in), `h2`                       | Full HTTP/2 support in hyper         |
| HTTP/3      | `h3`, `quinn` (QUIC), `s2n-quic` (AWS)        | Growing ecosystem, not yet dominant  |
| WebSocket   | `tokio-tungstenite`, `axum` (built-in)         | Full WS support                      |
| gRPC        | `tonic`                                        | Built on hyper + prost (protobuf)    |
| SSE         | `axum` (built-in), `eventsource-stream`        | Server-Sent Events                   |
| Unix Socket | `tokio::net::UnixStream`, `hyper-util`         | First-class support in tokio         |

## Web Frameworks

### Axum (Recommended)
Built by the Tokio team. Type-safe, ergonomic, modular. Uses the `tower` middleware ecosystem.

```rust
use axum::{routing::get, Router, Json};
use serde::Serialize;

#[derive(Serialize)]
struct Health { status: String }

async fn health() -> Json<Health> {
    Json(Health { status: "ok".into() })
}

#[tokio::main]
async fn main() {
    let app = Router::new().route("/health", get(health));
    let listener = tokio::net::TcpListener::bind("0.0.0.0:3000").await.unwrap();
    axum::serve(listener, app).await.unwrap();
}
```

### Actix-web
Mature, very fast (consistently tops TechEmpower benchmarks). Actor-based internally.
Slightly different API style — uses macros for route definitions.

### Other Options
- **Rocket** — developer-friendly, lots of magic via macros
- **Warp** — filter-based composition (by the hyper author)
- **Poem** — newer, ergonomic, OpenAPI-first

## CLI Tools

### Clap (Command Line Argument Parser)
The standard for CLI argument parsing in Rust. Derive-based API is clean:

```rust
use clap::Parser;

#[derive(Parser)]
#[command(name = "myapp", about = "A great CLI tool")]
struct Args {
    #[arg(short, long)]
    verbose: bool,

    #[arg(short, long, default_value = "config.toml")]
    config: String,
}

fn main() {
    let args = Args::parse();
}
```

### Other CLI Ecosystem
- **`dialoguer`** — interactive prompts
- **`indicatif`** — progress bars
- **`console`** — terminal colors and styling
- **`clap_complete`** — shell completion generation

## TUI (Terminal User Interface)

### Ratatui
The successor to `tui-rs`. Immediate-mode rendering for terminal UIs.

```rust
use ratatui::prelude::*;
use ratatui::widgets::{Block, Borders, Paragraph};

fn draw(frame: &mut Frame) {
    let block = Block::default().title("Hello").borders(Borders::ALL);
    let paragraph = Paragraph::new("Welcome to Ratatui").block(block);
    frame.render_widget(paragraph, frame.area());
}
```

- Supports crossterm, termion, and termwiz backends
- Rich widget set: tables, charts, lists, sparklines, gauges
- Used by: `bottom` (system monitor), `gitui`, `spotify-tui`

## Structured Logging

### Tracing
The standard for structured, async-aware diagnostics in Rust:

```rust
use tracing::{info, instrument, warn};

#[instrument]
async fn handle_request(user_id: u64) {
    info!(user_id, "Processing request");
    // spans propagate through async boundaries
    if let Err(e) = do_work().await {
        warn!(error = %e, "Work failed, retrying");
    }
}
```

- **`tracing-subscriber`** — configurable log output (JSON, pretty, compact)
- **`tracing-opentelemetry`** — export spans to Jaeger, Zipkin, OTLP
- Spans nest naturally with async code — no lost context across `.await` points

## Prometheus Metrics

```rust
use prometheus::{IntCounter, Histogram, register_int_counter, register_histogram};
use axum::{routing::get, Router};

lazy_static::lazy_static! {
    static ref REQUESTS: IntCounter = register_int_counter!(
        "http_requests_total", "Total HTTP requests"
    ).unwrap();
    static ref LATENCY: Histogram = register_histogram!(
        "http_request_duration_seconds", "Request latency"
    ).unwrap();
}

async fn metrics_handler() -> String {
    use prometheus::Encoder;
    let encoder = prometheus::TextEncoder::new();
    let mut buffer = String::new();
    encoder.encode_utf8(&prometheus::gather(), &mut buffer).unwrap();
    buffer
}
```

Alternative: **`metrics`** crate (facade pattern) with **`metrics-exporter-prometheus`**.

## OpenAPI

### Utoipa
Derive-based OpenAPI documentation generation:

```rust
use utoipa::OpenApi;
use utoipa::ToSchema;

#[derive(ToSchema, serde::Serialize)]
struct User {
    id: u64,
    name: String,
}

#[utoipa::path(get, path = "/users/{id}", responses(
    (status = 200, description = "User found", body = User),
    (status = 404, description = "User not found"),
))]
async fn get_user(/* ... */) { /* ... */ }

#[derive(OpenApi)]
#[openapi(paths(get_user), components(schemas(User)))]
struct ApiDoc;
```

- Integrates with axum, actix-web, rocket
- Swagger UI served via `utoipa-swagger-ui`
- Alternative: `aide` (axum-specific, more integrated)

## Health Checks

Typically implemented as simple HTTP endpoints. No standard library for this — most teams
write a `/health` and `/ready` endpoint manually:

```rust
async fn health() -> impl IntoResponse {
    StatusCode::OK
}

async fn ready(State(pool): State<PgPool>) -> impl IntoResponse {
    match pool.acquire().await {
        Ok(_) => StatusCode::OK,
        Err(_) => StatusCode::SERVICE_UNAVAILABLE,
    }
}
```

## Container / Cgroups Awareness

- Rust binaries read cgroup limits via `/proc/self/cgroup` and `/sys/fs/cgroup/`
- **`num_cpus`** crate is cgroup-aware (reads CPU quota)
- Tokio's thread pool respects `num_cpus` by default, so it auto-adapts in containers
- **`cgroups-rs`** crate for direct cgroup interaction
- No automatic memory limit awareness — must be handled manually or via allocator config

## Desktop GUI

- **Tauri** — Electron alternative using web frontend + Rust backend (~600KB vs Electron's ~150MB)
- **Dioxus** — React-like UI in Rust (web, desktop, mobile, TUI)
- **Iced** — Elm-inspired, pure Rust GUI
- **Slint** — declarative GUI with its own markup language
- **egui** — immediate-mode GUI (great for tools and debug UIs)
- **gtk-rs** — GTK4 bindings
- **Druid** — data-first Rust GUI (experimental, by the Xi editor team)

## WASM Support

Rust has first-class WebAssembly support:

- **`wasm-pack`** — build, test, and publish Rust WASM packages
- **`wasm-bindgen`** — bridge between Rust and JavaScript
- **`web-sys`** — bindings to Web APIs (DOM, fetch, etc.)
- **`js-sys`** — bindings to JavaScript built-ins
- Typical WASM binary size: 30KB-500KB (after wasm-opt)
- Used in production by Figma, Cloudflare Workers, Shopify
- WASI (WebAssembly System Interface) support for server-side WASM

See also: [RUST_WASM.md](RUST_WASM.md) for detailed WebAssembly coverage.

## Fat Binary / Distribution

### Static Linking with musl
```bash
# Cross-compile a fully static Linux binary
rustup target add x86_64-unknown-linux-musl
cargo build --release --target x86_64-unknown-linux-musl
# Result: single binary, ~2-5MB for a typical web service (after strip)
```

### Cross-compilation
- **`cross`** tool — Docker-based cross-compilation (just replace `cargo` with `cross`)
- Supports dozens of targets: Linux (x86, ARM, MIPS), macOS, Windows, FreeBSD, Android, iOS
- `cargo-zigbuild` — use Zig as a linker for easier cross-compilation

### Distribution
- Single static binary — copy and run, no runtime needed
- `cargo install` from crates.io
- `cargo-dist` — automated release builds and GitHub releases
- `cargo-deb` / `cargo-rpm` — package as .deb / .rpm

## Embeddability

- Rust can expose C ABI functions (`#[no_mangle] extern "C"`)
- Embeddable in Python (`pyo3`/`maturin`), Ruby (`magnus`), Node.js (`napi-rs`), Erlang/Elixir (`rustler`)
- Can call C libraries via `bindgen` (auto-generates Rust FFI bindings from C headers)
- No runtime to embed — just the compiled code

## Build & Dev Tools

- **Cargo** — build system, package manager, test runner, doc generator (all-in-one)
- **Clippy** — official linter (hundreds of lints, highly configurable)
- **Rustfmt** — official code formatter
- **rust-analyzer** — LSP server for IDE support
- **Miri** — interpreter for detecting undefined behavior
- **cargo-bench** + **criterion** — benchmarking
- **cargo-audit** — check dependencies for known vulnerabilities
- **cargo-deny** — license and dependency policy enforcement

## Notable Projects Built in Rust

- **Firefox** (Stylo CSS engine, WebRender) — Mozilla's original motivation for Rust
- **Servo** — experimental browser engine
- **ripgrep (rg)** — fastest grep replacement
- **Alacritty** — GPU-accelerated terminal emulator
- **Cloudflare Workers** — WASM runtime at edge
- **Discord** — rewrote read states service from Go to Rust (10x latency improvement)
- **Linux kernel** — Rust accepted as second language (since 6.1)
- **Android** — Rust used in Bluetooth stack, key management, DNS-over-HTTPS
- **Deno** — JavaScript/TypeScript runtime
- **SurrealDB** — multi-model database
- **Turbopack** — Vercel's successor to Webpack (Rust-based)
- **Zed** — high-performance code editor

## Special Features

- **Zero-cost abstractions** — iterators, closures, traits compile to the same code as hand-written loops
- **Fearless concurrency** — type system prevents data races, period
- **No garbage collector** — deterministic performance, no GC pauses
- **Cargo** — arguably the best package manager in any language
- **Editions** — language evolves without breaking old code
- **Procedural macros** — code generation at compile time (powerful metaprogramming)
- **Unsafe** — opt-in escape hatch for raw pointers, FFI, etc. (auditable boundary)

## Strengths

1. Memory safety without GC — unique value proposition
2. Performance on par with C/C++ in benchmarks
3. Excellent tooling (Cargo, Clippy, rust-analyzer)
4. Strong type system catches entire classes of bugs at compile time
5. Vibrant ecosystem — crates.io has 150,000+ crates
6. Predictable performance — no GC pauses, no JIT warmup
7. Cross-compilation and static linking make deployment trivial
8. WASM support is best-in-class
9. Growing industry adoption (FAANG, startups, infrastructure)
10. Active, welcoming community

## Weaknesses

1. Steep learning curve (ownership, lifetimes, borrow checker)
2. Slow compile times (mitigated by incremental compilation, but still slow)
3. Async ecosystem is fragmented (different runtimes, not fully unified)
4. Verbose compared to Go or Python for simple tasks
5. Limited GUI ecosystem (improving but immature vs Qt/Electron)
6. No stable ABI — cannot distribute shared libraries easily
7. Dependency bloat (many small crates, deep dependency trees)
8. Prototyping is slower than in dynamic languages
9. Pattern of "fighting the borrow checker" for graph/tree structures
10. Orphan rule limits extensibility in some cases

## When to Choose Rust

**Choose Rust when:**
- You need C/C++ performance with memory safety guarantees
- Building CLI tools, system utilities, or infrastructure software
- WebAssembly is a target (browser or edge computing)
- Correctness is critical (financial systems, embedded, safety-critical)
- You want single static binary deployment
- Building performance-critical services (proxies, databases, game engines)
- Replacing C/C++ in an existing codebase incrementally (FFI is excellent)

**Avoid Rust when:**
- Rapid prototyping is the priority (use Python, Go, or Elixir)
- Team has no systems programming experience and timeline is tight
- Simple CRUD web apps (Go, Elixir, or Java are more productive)
- You need a huge ecosystem of business-logic libraries (Java/Python win here)
- Dynamic scripting or glue code (Python, Ruby, Bash)
