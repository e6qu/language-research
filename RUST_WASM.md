# Rust + WebAssembly (WASM)

## Overview

Rust has first-class WebAssembly support, making it one of the best languages for
compiling to WASM. The toolchain is mature, the output is compact, and the interop
with JavaScript is seamless via `wasm-bindgen`.

WebAssembly (WASM) is a binary instruction format designed as a portable compilation
target. It runs in browsers (all major browsers since 2017) and increasingly on servers
via WASI (WebAssembly System Interface).

### Why Rust for WASM?

1. No garbage collector — WASM has no built-in GC (GC proposal is recent), so Rust's
   ownership model maps perfectly
2. Small binary sizes — no runtime to ship
3. Predictable performance — no GC pauses in the browser
4. Memory safety — same guarantees as native Rust
5. Mature tooling — `wasm-pack` is production-ready
6. Strong community — Rust consistently leads WASM adoption

## Core Toolchain

### wasm-pack
The primary build tool for Rust WASM projects. Handles compilation, optimization,
JavaScript bindings generation, and npm package creation.

```bash
# Install
cargo install wasm-pack

# Build for bundlers (webpack, vite, etc.)
wasm-pack build --target bundler

# Build for direct browser use (no bundler needed)
wasm-pack build --target web

# Build for Node.js
wasm-pack build --target nodejs

# Build with size optimization
wasm-pack build --release -- -C opt-level=s
```

Output structure:
```
pkg/
  my_crate_bg.wasm    # The compiled WASM binary
  my_crate_bg.wasm.d.ts
  my_crate.js          # JavaScript glue code
  my_crate.d.ts        # TypeScript type definitions
  package.json         # Ready to publish to npm
```

### wasm-bindgen
The bridge between Rust and JavaScript. Enables:
- Calling JavaScript from Rust
- Exposing Rust functions to JavaScript
- Passing complex types across the boundary
- Async interop (Rust futures <-> JS Promises)

```rust
use wasm_bindgen::prelude::*;

// Expose a Rust function to JavaScript
#[wasm_bindgen]
pub fn greet(name: &str) -> String {
    format!("Hello, {name}!")
}

// Import a JavaScript function into Rust
#[wasm_bindgen]
extern "C" {
    fn alert(s: &str);

    #[wasm_bindgen(js_namespace = console)]
    fn log(s: &str);
}

// Use JavaScript's console.log from Rust
#[wasm_bindgen]
pub fn init() {
    log("WASM module initialized");
}
```

### web-sys
Raw bindings to Web APIs. Auto-generated from WebIDL specifications.
Feature-gated — you only include the APIs you use.

```rust
use wasm_bindgen::prelude::*;
use web_sys::{Document, Element, HtmlElement, Window};

#[wasm_bindgen]
pub fn manipulate_dom() -> Result<(), JsValue> {
    let window: Window = web_sys::window().unwrap();
    let document: Document = window.document().unwrap();

    let element: Element = document.create_element("div")?;
    element.set_inner_html("<p>Created from Rust!</p>");
    element.set_class_name("rust-generated");

    let body: HtmlElement = document.body().unwrap();
    body.append_child(&element)?;

    Ok(())
}
```

```toml
# Cargo.toml — enable only the features you need
[dependencies.web-sys]
version = "0.3"
features = [
    "Document",
    "Element",
    "HtmlElement",
    "Window",
    "console",
    "Performance",
    "Request",
    "RequestInit",
    "Response",
    "Headers",
]
```

### js-sys
Bindings to JavaScript built-in objects (not Web APIs):

```rust
use js_sys::{Array, Date, JSON, Math, Object, Promise, Reflect};

#[wasm_bindgen]
pub fn get_random() -> f64 {
    Math::random()
}

#[wasm_bindgen]
pub fn current_timestamp() -> f64 {
    Date::now()
}

#[wasm_bindgen]
pub fn parse_json(input: &str) -> Result<JsValue, JsValue> {
    JSON::parse(input)
}
```

## Project Setup

### Minimal Cargo.toml
```toml
[package]
name = "my-wasm-lib"
version = "0.1.0"
edition = "2024"

[lib]
crate-type = ["cdylib", "rlib"]

[dependencies]
wasm-bindgen = "0.2"
web-sys = { version = "0.3", features = ["console"] }
js-sys = "0.3"
serde = { version = "1", features = ["derive"] }
serde-wasm-bindgen = "0.6"

[profile.release]
opt-level = "s"       # Optimize for size
lto = true            # Link-Time Optimization
codegen-units = 1     # Better optimization, slower build
strip = true          # Strip debug symbols
```

### JavaScript Integration
```javascript
// Using with a bundler (webpack, vite)
import init, { greet } from './pkg/my_wasm_lib';

async function main() {
    await init();  // Initialize the WASM module
    console.log(greet("World"));  // "Hello, World!"
}
main();
```

```html
<!-- Direct browser use (no bundler) -->
<script type="module">
    import init, { greet } from './pkg/my_wasm_lib.js';
    await init();
    document.body.textContent = greet("Browser");
</script>
```

## Async Interop

Rust futures map to JavaScript Promises via `wasm-bindgen-futures`:

```rust
use wasm_bindgen::prelude::*;
use wasm_bindgen_futures::JsFuture;
use web_sys::{Request, RequestInit, Response};

#[wasm_bindgen]
pub async fn fetch_data(url: &str) -> Result<JsValue, JsValue> {
    let mut opts = RequestInit::new();
    opts.method("GET");

    let request = Request::new_with_str_and_init(url, &opts)?;
    let window = web_sys::window().unwrap();
    let resp_value = JsFuture::from(window.fetch_with_request(&request)).await?;
    let resp: Response = resp_value.dyn_into()?;
    let json = JsFuture::from(resp.json()?).await?;
    Ok(json)
}
```

## Passing Complex Types

### With serde-wasm-bindgen
```rust
use serde::{Deserialize, Serialize};
use wasm_bindgen::prelude::*;

#[derive(Serialize, Deserialize)]
pub struct Config {
    pub width: u32,
    pub height: u32,
    pub title: String,
    pub options: Vec<String>,
}

#[wasm_bindgen]
pub fn process_config(val: JsValue) -> Result<JsValue, JsValue> {
    let config: Config = serde_wasm_bindgen::from_value(val)?;
    let processed = Config {
        title: format!("Processed: {}", config.title),
        ..config
    };
    Ok(serde_wasm_bindgen::to_value(&processed)?)
}
```

### With wasm_bindgen directly (for simple structs)
```rust
#[wasm_bindgen]
pub struct Point {
    x: f64,
    y: f64,
}

#[wasm_bindgen]
impl Point {
    #[wasm_bindgen(constructor)]
    pub fn new(x: f64, y: f64) -> Point {
        Point { x, y }
    }

    pub fn distance(&self, other: &Point) -> f64 {
        ((self.x - other.x).powi(2) + (self.y - other.y).powi(2)).sqrt()
    }
}
```

## Testing

```rust
// In-browser tests via wasm-pack test
#[cfg(test)]
mod tests {
    use wasm_bindgen_test::*;

    wasm_bindgen_test_configure!(run_in_browser);

    #[wasm_bindgen_test]
    fn test_greet() {
        assert_eq!(super::greet("Rust"), "Hello, Rust!");
    }

    #[wasm_bindgen_test]
    async fn test_async_fetch() {
        // This runs in a real browser via headless Chrome/Firefox
        let result = super::fetch_data("https://httpbin.org/get").await;
        assert!(result.is_ok());
    }
}
```

```bash
# Run tests in headless browser
wasm-pack test --headless --chrome
wasm-pack test --headless --firefox

# Run tests in Node.js
wasm-pack test --node
```

## Binary Size

### Typical sizes (after wasm-opt, release mode)

| Scenario                        | Size      |
|---------------------------------|-----------|
| Minimal "hello world"           | ~15-30 KB |
| JSON processing library         | ~50-100 KB|
| Image manipulation              | ~100-300 KB|
| Complex app (e.g., markdown)    | ~200-500 KB|
| Full game engine                | ~1-5 MB   |

### Size Optimization Techniques
1. `opt-level = "s"` or `"z"` in Cargo.toml (optimize for size)
2. `lto = true` — link-time optimization eliminates dead code
3. `wasm-opt -Os` — Binaryen optimizer (wasm-pack runs this automatically)
4. `codegen-units = 1` — better whole-program optimization
5. Avoid `format!` / `std::fmt` when possible (adds ~10-20KB)
6. Use `#[wasm_bindgen(skip)]` on fields you don't need exposed
7. `wee_alloc` — tiny allocator (~1KB vs default ~10KB) — tradeoff: slower allocation
8. `twiggy` — analyze what's taking space in your WASM binary

```bash
# Analyze binary size
cargo install twiggy
twiggy top pkg/my_crate_bg.wasm
twiggy dominators pkg/my_crate_bg.wasm
```

## Common Use Cases for Rust-WASM

1. **Compute-intensive browser work** — image/video processing, compression, hashing
2. **Games** — via Bevy (has WASM target), or custom engines
3. **Figma** — entire rendering engine is Rust compiled to WASM
4. **Cloudflare Workers** — server-side WASM at the edge
5. **Autodesk** — CAD computations in the browser
6. **Audio processing** — real-time DSP in the browser
7. **Crypto/blockchain** — wallets, signing, zero-knowledge proofs
8. **Scientific visualization** — large dataset rendering
9. **PDF generation/parsing** — in-browser document handling
10. **Code editors** — syntax highlighting, language servers

## WASI (Server-Side WASM)

WebAssembly System Interface — run WASM outside the browser:

```rust
// Standard Rust code, compiled to WASI target
fn main() {
    println!("Hello from WASI!");
    let contents = std::fs::read_to_string("input.txt").unwrap();
    println!("File contents: {contents}");
}
```

```bash
# Build for WASI
rustup target add wasm32-wasi
cargo build --target wasm32-wasi --release

# Run with Wasmtime
wasmtime target/wasm32-wasi/release/my_app.wasm

# Run with Wasmer
wasmer run target/wasm32-wasi/release/my_app.wasm
```

Runtimes: **Wasmtime** (Bytecode Alliance), **Wasmer**, **WasmEdge**, **Spin** (Fermyon).

## Comparison: Rust-WASM vs Elm vs Plain JavaScript

### Rust-WASM

| Aspect            | Rust-WASM                                              |
|-------------------|--------------------------------------------------------|
| **Best for**      | Compute-heavy tasks, porting native code to browser    |
| **Bundle size**   | 30KB-500KB (WASM binary) + JS glue                    |
| **DOM access**    | Via web-sys (verbose but complete)                     |
| **UI framework**  | Yew, Leptos, Dioxus (React-like in Rust)               |
| **Learning curve**| Steep (Rust + WASM concepts)                           |
| **Performance**   | Near-native for compute; DOM interop has overhead      |
| **Type safety**   | Excellent (Rust's full type system)                    |
| **Ecosystem**     | Growing; JS interop means access to npm when needed    |
| **Debugging**     | Improving but harder than JS (source maps, console)    |
| **Build time**    | Slow (30s-2min for incremental)                        |

### Elm

| Aspect            | Elm                                                    |
|-------------------|--------------------------------------------------------|
| **Best for**      | UI-heavy SPAs with strong correctness guarantees       |
| **Bundle size**   | 30-100KB (compiled JS, gzipped)                        |
| **DOM access**    | Virtual DOM, declarative (Elm Architecture)            |
| **UI framework**  | Elm IS the framework (built-in)                        |
| **Learning curve**| Moderate (ML-family syntax, but simple model)          |
| **Performance**   | Good for UI (optimized virtual DOM); not for compute   |
| **Type safety**   | Excellent (Hindley-Milner, no runtime exceptions)      |
| **Ecosystem**     | Small, curated; limited JS interop (ports)             |
| **Debugging**     | Excellent (time-travel debugger, no runtime errors)    |
| **Build time**    | Fast (<5s for most projects)                           |

### Plain JavaScript / TypeScript

| Aspect            | JavaScript/TypeScript                                  |
|-------------------|--------------------------------------------------------|
| **Best for**      | General web development, rapid prototyping             |
| **Bundle size**   | Varies wildly (0KB to many MB with dependencies)       |
| **DOM access**    | Native, direct, zero overhead                          |
| **UI framework**  | React, Vue, Svelte, Angular, Solid, etc.               |
| **Learning curve**| Low to moderate                                        |
| **Performance**   | Good (V8 JIT is excellent); unpredictable GC pauses    |
| **Type safety**   | TypeScript adds types but they're erasable/unsound     |
| **Ecosystem**     | Massive (npm has 2M+ packages)                         |
| **Debugging**     | Excellent (browser devtools)                           |
| **Build time**    | Fast (with modern tools like Vite, esbuild)            |

### Decision Guide

**Choose Rust-WASM when:**
- CPU-intensive computation in the browser (image processing, physics, crypto)
- Porting existing Rust/C/C++ code to the browser
- You need predictable, near-native performance (games, simulations)
- Building Cloudflare Workers or edge computing functions
- Security-critical code that benefits from Rust's safety guarantees

**Choose Elm when:**
- Building a single-page application with complex UI state
- You want zero runtime exceptions guaranteed by the compiler
- Team values simplicity and correctness over flexibility
- The application is primarily UI logic, not heavy computation
- You can live within Elm's controlled ecosystem

**Choose Plain JS/TS when:**
- General web development (most projects)
- DOM-heavy applications with minimal computation
- Rapid prototyping and iteration
- You need the broadest possible library ecosystem
- Team expertise is in JavaScript
- SEO and SSR are important (mature solutions in Next.js, Nuxt, etc.)

**Hybrid approach (common in practice):**
- Use JS/TS for UI and DOM manipulation
- Use Rust-WASM for performance-critical modules (image processing, parsing, etc.)
- This avoids the DOM interop overhead of pure Rust-WASM frameworks

## Frameworks for Full Rust-WASM Web Apps

If you want to build entire web apps in Rust (compiling to WASM):

- **Leptos** — fine-grained reactivity, SSR support, closest to SolidJS
- **Yew** — React-like, most mature Rust WASM framework
- **Dioxus** — React-like, cross-platform (web, desktop, mobile, TUI)
- **Sycamore** — reactive, no virtual DOM
- **Perseus** — SSR/SSG framework built on Sycamore

These are viable for applications where the team is Rust-native, but for typical web
apps, the JS/TS ecosystem remains more productive and better supported.

## Strengths

1. Best-in-class WASM binary sizes (no GC runtime to ship)
2. Near-native performance for compute-heavy workloads
3. Full Rust type safety carries over to WASM
4. Excellent tooling (wasm-pack, wasm-bindgen, twiggy)
5. Strong async interop with JavaScript Promises
6. Growing ecosystem of WASM-specific crates
7. Same code can target native and WASM (with feature flags)
8. WASI support enables server-side and edge computing

## Weaknesses

1. DOM interop has overhead (crossing the JS-WASM boundary costs cycles)
2. Debugging is harder than pure JavaScript
3. Build times are slower than JS toolchains
4. String passing across the boundary requires copying
5. Not all Rust crates work in WASM (anything using OS-specific APIs)
6. Browser devtools support for WASM is still maturing
7. Full web app frameworks (Yew, Leptos) have smaller communities than React/Vue
8. Initial WASM module load/compile time can be noticeable for large modules
