# Clojure — A Lisp for the JVM

## Overview

Clojure is a dynamic, functional Lisp dialect that runs on the Java Virtual Machine. Designed
by Rich Hickey and first released in 2007, Clojure emphasizes immutability, persistent data
structures, and a pragmatic approach to concurrency. It is homoiconic — code is data (lists,
vectors, maps) — enabling a powerful macro system.

- **Current stable**: 1.12.2 (August 2025)
- **Paradigm**: Functional, concurrent, Lisp, with optional OOP interop via Java
- **Typing**: Dynamic, strong (with optional spec/schema systems)
- **Runtime**: JVM (also ClojureScript for JS, ClojureCLR for .NET)
- **Package manager**: Clojars (~30,000+ libraries), plus full access to Maven Central
- **Build tools**: deps.edn/tools.deps (official), Leiningen (community standard)

### Design Philosophy
Clojure is opinionated about state management. Values are immutable by default. Identity
(things that change over time) is managed through explicit reference types (atoms, refs,
agents) with well-defined concurrency semantics. This separation of identity and state
eliminates entire categories of concurrency bugs. Rich Hickey's talks ("Are We There Yet?",
"Simple Made Easy", "The Value of Values") are foundational to understanding the language's
design decisions.

## Type System

### Dynamic Typing with Optional Specs/Schemas

Clojure is dynamically typed — no type annotations required. The community has developed
multiple approaches to adding structure:

**clojure.spec** (built-in since 1.9) — describe the shape of data and functions with
predicates. Specs are not types; they are runtime-checkable contracts.
```clojure
(require '[clojure.spec.alpha :as s])

(s/def ::name string?)
(s/def ::age (s/and int? #(> % 0)))
(s/def ::person (s/keys :req [::name ::age]))

(s/valid? ::person {::name "Alice" ::age 30}) ;=> true
(s/explain ::person {::name "Alice" ::age -1}) ;=> prints explanation
```

**Malli** (metosin) — high-performance, data-driven schema library. Gaining significant
traction as the modern alternative to spec. Supports validation, transformation, generation,
error messages, and JSON Schema / OpenAPI output. Active development in 2025 includes
recursive schema compilation and schema simplification.

**core.typed** — optional static type system (Typed Clojure). Academically interesting but
low adoption in production. Most teams prefer spec or Malli.

### Strengths
- Rapid prototyping — no ceremony, no type boilerplate
- Spec and Malli provide data validation, generative testing, and documentation in one tool
- Full access to Java's type system via interop when needed
- Destructuring makes working with dynamic data ergonomic

### Weaknesses
- Runtime errors that static types would catch at compile time
- Refactoring large codebases without types requires discipline and good test coverage
- spec's syntax is verbose; Malli addresses this but adds a dependency
- No compile-time type checking by default

## Error Handling

Clojure uses JVM exceptions — `try`/`catch`/`finally` with `throw`. There are no checked
exceptions (Clojure ignores Java's checked exception requirement).

```clojure
(try
  (do-risky-thing)
  (catch ExceptionInfo e
    (let [data (ex-data e)]
      (log/error "Structured error" data)))
  (catch Exception e
    (log/error "Unexpected error" (.getMessage e)))
  (finally
    (cleanup)))
```

**`ex-info` / `ex-data`** — Clojure's idiomatic way to create structured errors. `ex-info`
creates an `ExceptionInfo` with a message, a data map, and an optional cause. `ex-data`
extracts the map. This is far more useful than Java's string-only exception messages.

```clojure
(throw (ex-info "User not found" {:user-id 42 :status 404}))
```

**Comparison**: Unlike Rust's `Result<T,E>` or Go's `(value, error)` tuples, Clojure uses
exceptions for error flow. This is less explicit but more ergonomic for deeply nested call
stacks. Libraries like `failjure` and `cats` provide monadic error handling for those who
prefer it.

## Retries

No built-in retry mechanism. Library options:

- **diehard** — the standard choice. Wraps Failsafe (Java). Provides retry with backoff,
  circuit breakers, rate limiters, and bulkheads. Production-proven.
  ```clojure
  (require '[diehard.core :as dh])

  (dh/with-retry {:retry-on Exception
                   :max-retries 3
                   :backoff-ms [100 2000] ;; exponential 100ms -> 2s
                   :on-retry (fn [_ e] (log/warn "Retrying..." e))}
    (http/get "https://api.example.com/data"))
  ```
- **again** — simpler retry-only library with configurable strategies
- Manual retry loops are straightforward given Clojure's functional style

## Concurrency

Clojure's concurrency story is arguably its killer feature. The language provides multiple
concurrency primitives, each designed for a specific use case.

### Reference Types

**Atoms** — independent, synchronous, uncoordinated state. The workhorse for most state
management. Uses compare-and-swap (CAS) internally.
```clojure
(def counter (atom 0))
(swap! counter inc)        ;=> 1
(swap! counter + 10)       ;=> 11
@counter                   ;=> 11 (deref)
```

**Refs + STM** — coordinated, synchronous change of multiple values within a transaction.
Software Transactional Memory (STM) ensures consistency without manual locking.
```clojure
(def account-a (ref 1000))
(def account-b (ref 500))

(dosync
  (alter account-a - 200)
  (alter account-b + 200))
;; Both changes are atomic — no inconsistent intermediate state
```

**Agents** — independent, asynchronous state changes. Dispatched actions are queued and
executed sequentially per agent, but different agents run concurrently.
```clojure
(def logger (agent []))
(send logger conj "event-1")  ;; async, returns immediately
(send logger conj "event-2")
```

**Vars** — thread-local dynamic bindings. Used for configuration, not general state.

### Higher-Level Concurrency

**Futures and Promises** — `future` runs a body on a thread pool and returns a deref-able
value. `promise` is a write-once container.
```clojure
(def result (future (expensive-computation)))
@result ;; blocks until done
```

**pmap** — parallel map over a sequence, using a thread pool.

**Reducers / Transducers** — composable, parallel-friendly data transformations. Transducers
decouple the transformation from the data source, enabling reuse across sequences, channels,
and streams without intermediate allocations.

**core.async** — Go-style CSP channels with lightweight "go blocks" (parked threads, not OS
threads). Enables complex async coordination.
```clojure
(require '[clojure.core.async :as async :refer [go chan <! >! <!!]])

(let [c (chan 10)]
  (go (>! c "hello"))        ;; non-blocking put
  (go (println (<! c))))     ;; non-blocking take
```

### Comparison with Go and BEAM

| Feature | Clojure | Go | BEAM |
|---|---|---|---|
| Lightweight concurrency | core.async go blocks | Goroutines (~2KB) | Processes (~0.5KB) |
| Communication | Channels (core.async) | Channels (built-in) | Message passing |
| Shared state | Atoms, Refs (STM) | sync.Mutex, sync.Map | No shared state (process isolation) |
| Coordination | STM transactions | sync.WaitGroup, errgroup | Supervisors, links |
| Fault isolation | JVM exceptions (shared heap) | Goroutine panics can crash | Full process isolation |
| Preemption | No (cooperative in go blocks) | Yes (goroutine scheduler) | Yes (reduction counting) |

Clojure's STM is unique — no other mainstream language has built-in software transactional
memory. However, core.async go blocks are not preemptive (unlike goroutines or BEAM
processes), so a blocking call inside a go block can starve the thread pool.

## Network Protocols

| Protocol | Library | Notes |
|---|---|---|
| HTTP/1.1 | `clj-http`, `http-kit` | clj-http wraps Apache HttpClient; http-kit is async |
| HTTP/2 | `aleph` (0.7+), `java.net.http` | Aleph added HTTP/2 client and server support |
| WebSocket | `http-kit`, `Sente`, `aleph` | Sente adds real-time abstractions (auto-reconnect, multiplexing) |
| gRPC | `protojure`, `lein-protobuf` | Less mature than Go/Java gRPC ecosystem |
| SSE | `http-kit`, Ring streaming | Straightforward with Ring async handlers |
| TCP/UDP | `aleph` (Netty-based) | Raw TCP/UDP via Netty under the hood |

## Web Frameworks

Clojure's web ecosystem is built on the **Ring** specification — a minimal abstraction where
an HTTP server is a function from request map to response map. Middleware is function
composition. This is Clojure's equivalent of Go's `net/http` or Ruby's Rack.

### Ring + Reitit (Modern Standard)
```clojure
(require '[reitit.ring :as ring])

(def app
  (ring/ring-handler
    (ring/router
      [["/api/health" {:get (fn [_] {:status 200 :body "ok"})}]
       ["/api/users/:id" {:get get-user}]])))
```

**Reitit** (metosin) is the modern routing library — data-driven, fast, supports coercion
with Malli, and integrates with Swagger/OpenAPI. Tested against Java 11, 17, 21, and 25.

### Other Frameworks
- **Pedestal** — production-grade, interceptor-based (used at Nubank)
- **Compojure** — macro-based routing (older, simpler)
- **Luminus / Kit** — batteries-included project templates (Ring + Reitit + Malli + more)
- **http-kit** — lightweight, async HTTP server and client (600 lines of Java + Clojure)
- **Biff** — batteries-included framework with Ring, Reitit, XTDB, and Malli

## CLI Tools

### tools.cli (Standard Library)
```clojure
(def cli-options
  [["-p" "--port PORT" "Port number" :default 3000 :parse-fn #(Integer/parseInt %)]
   ["-v" "--verbose" "Verbose output"]
   ["-h" "--help"]])
```

### Babashka (Game Changer)
Babashka is a GraalVM native-image compiled Clojure interpreter. It starts in **~5ms**
(vs ~1-2 seconds for JVM Clojure), making Clojure viable for shell scripting, CLI tools,
and quick automation tasks. Current version: 1.12.214 (January 2026).

- Includes batteries: tools.cli, cheshire (JSON), babashka.fs, babashka.process, java.time
- Built-in task runner (replaces make/just/npm scripts)
- Runs most Clojure code unmodified (uses SCI interpreter internally)
- Supports pods (external process plugins) for extending capabilities

```bash
#!/usr/bin/env bb
;; save as script.clj, chmod +x, run directly
(require '[babashka.fs :as fs])
(doseq [f (fs/glob "." "**/*.clj")]
  (println (str f)))
```

### GraalVM native-image
For AOT-compiled native binaries from full Clojure — ~10x faster startup, ~11x less memory
than JVM. Requires `:gen-class` and reflection configuration. Tools: `clj.native-image`,
`lein-native-image`, `cambada`.

## TUI (Terminal User Interface)

- **lanterna** (`clojure-lanterna`) — ncurses-style terminal UI library
- **clojure-term-colors** — ANSI color output
- **Babashka + raw ANSI** — many TUI scripts use Babashka with direct ANSI escape codes
- Not a strength — most Clojure developers build web UIs or use the REPL directly

## Structured Logging

### mulog (Recommended)
Event-based structured logging. Replaces text-based logs with rich, queryable events.
```clojure
(require '[com.brunobonacci.mulog :as mu])

(mu/start-publisher! {:type :console :pretty? true})

(mu/log ::request-handled
  :method "GET" :path "/api/users" :status 200 :latency-ms 12)

(mu/trace ::database-query [:query sql]
  (jdbc/execute! db sql))
;; automatically captures duration, outcome, and exception if thrown
```

### Other Options
- **tools.logging** — facade over SLF4J/Logback (Java standard approach)
- **Cambium** — structured logging on top of SLF4J with MDC context
- **Timbre** — pure Clojure logging (no Java dependency)

## Prometheus Metrics

### iapetos
Clojure wrapper for the Prometheus Java Client. Idiomatic and maintained under clj-commons.

```clojure
(require '[iapetos.core :as prometheus])

(def registry
  (-> (prometheus/collector-registry)
      (prometheus/register
        (prometheus/counter :app/requests-total {:labels [:method :path]})
        (prometheus/histogram :app/request-duration-seconds))))

(prometheus/inc registry :app/requests-total {:method "GET" :path "/api"})

;; Expose /metrics endpoint via Ring handler
```

Alternative: **mulog-prometheus** publisher — export mulog events directly as Prometheus
metrics. Unifies logging and metrics in one system.

## OpenAPI

The modern Clojure stack for OpenAPI:

**Reitit + Malli + Swagger** — Reitit's `reitit-swagger` module auto-generates OpenAPI
specs from route definitions and Malli schemas. This is the recommended approach.

```clojure
["/api/users/:id"
 {:get {:summary "Get user by ID"
        :parameters {:path [:map [:id int?]]}
        :responses {200 {:body [:map [:name string?] [:age int?]]}}
        :handler get-user}}]
;; Swagger UI served automatically at /swagger
```

**spec-tools** — generates OpenAPI from clojure.spec definitions (older approach).

## Health Checks

No dedicated library — Clojure's Ring ecosystem makes this trivial:

```clojure
(defn health-handler [_]
  {:status 200 :body {:status "ok"}})

(defn ready-handler [{:keys [db]}]
  (if (try (.isValid (.getConnection db) 1) (catch Exception _ false))
    {:status 200 :body {:status "ready"}}
    {:status 503 :body {:status "not ready"}}))
```

For Kubernetes: expose `/healthz` (liveness) and `/readyz` (readiness) as Ring routes.
Libraries like `diehard` can wrap health checks with circuit breakers.

## Container / Cgroups Awareness

Clojure runs on the JVM, so container awareness is inherited from Java:

- **JVM 10+** automatically detects cgroup CPU and memory limits
- `-XX:+UseContainerSupport` (on by default since JDK 10)
- `-XX:MaxRAMPercentage=75.0` — set heap as percentage of container memory limit
- Clojure 1.12 supports JDK 21 virtual threads — requires lock-based (not synchronized) blocking
- Babashka binaries are native and have no JVM overhead in containers (~20MB image)

## Desktop GUI

- **cljfx** — declarative, functional wrapper for JavaFX. React-like architecture with
  immutable state management. Supports `jpackage` for native installers.
- **Humble UI** (tonsky) — Clojure desktop UI framework, no Electron, no JavaScript. JVM +
  Skia native rendering. Under active development.
- **Swing interop** — direct access to Java Swing via Clojure's Java interop (verbose but works)
- **Seesaw** — Swing wrapper with more idiomatic Clojure API

## WASM Support

WASM support for Clojure is experimental and fragmented:

- **Cherry** — ClojureScript subset compiler. Can compile to JS, then convert to WASM via
  Javy. Output is large (~2-7MB). Not production-ready.
- **SCI in WASM** — the Small Clojure Interpreter can run inside a WASM environment
- **TeaVM** — compiles JVM bytecode (including Clojure) to WASM
- **ClojureScript + JS interop** — call WASM modules from ClojureScript through JS interop

WASM is not a Clojure strength. For WASM targets, Rust is the better choice.

## Fat Binary / Distribution

### Uberjar (Standard)
```bash
# Leiningen
lein uberjar
# Result: single JAR with all dependencies, ~20-50MB for a typical web service

# tools.deps + depstar/tools.build
clj -T:build uber
```

### GraalVM native-image
Compile uberjar to a native binary. ~10x faster startup, ~11x less memory.
```bash
native-image -jar myapp.jar myapp
# Result: native binary, ~30-80MB, starts in <100ms
```

### Babashka
For CLI tools and scripts — instant startup (~5ms), single native binary (~80MB includes
the interpreter). No compilation step needed.

### jlink (JDK 9+)
Create a custom JRE with only the modules your app needs, reducing distribution size.

## Embeddability

- **SCI (Small Clojure Interpreter)** — configurable Clojure interpreter designed for
  embedding. Used by Babashka, Clerk, nbb, and many other tools. Sandboxable — you control
  which namespaces and functions are available.
- **GraalVM polyglot** — embed Clojure in polyglot applications via GraalVM's Truffle framework
- **Java interop** — Clojure can be called from Java as a library (compile with AOT)

## Notable Projects

- **Datomic** — immutable, time-aware database (by Rich Hickey / Nubank)
- **Metabase** — open-source business intelligence and analytics
- **Riemann** — distributed systems monitoring
- **Overtone** — live-coding music synthesis
- **Onyx** — distributed computation platform
- **LightTable** — IDE experiment (historically significant, now archived)

### Companies Using Clojure in Production
- **Nubank** — world's largest digital bank, 100M+ customers, 1000+ Clojure microservices
- **Cisco** — network management tools
- **Walmart** — supply chain systems
- **Netflix** — data pipeline tooling
- **Apple** — internal tools
- **CircleCI** — CI/CD platform (originally Clojure-first)
- **Puppet** — infrastructure automation
- **Funding Circle** — peer-to-peer lending
- **Pitch** — presentation software

## Ecosystem

### Build Tools
- **deps.edn / tools.deps** — official, minimal, declarative dependency management
- **Leiningen** — community standard build tool (project.clj), richer task ecosystem

### IDEs and Editors
- **CIDER** (Emacs) — the gold standard for Clojure development, deep REPL integration
- **Calva** (VS Code) — excellent, actively maintained, good for newcomers
- **Cursive** (IntelliJ) — full IDE experience, structural editing, Java interop support
- **vim-fireplace / Conjure** (Vim/Neovim) — REPL-connected Clojure editing

### Key Libraries
- **next.jdbc** — modern JDBC wrapper (Sean Corfield)
- **HoneySQL** — SQL as Clojure data structures
- **cheshire** — fast JSON encoding/decoding
- **mount / integrant / component** — system lifecycle management
- **clj-kondo** — static linter (catches errors without running code)
- **portal / reveal** — data visualization and inspection tools

## Special Features

**Persistent Data Structures** — Clojure's lists, vectors, maps, and sets are immutable and
use structural sharing (hash array mapped tries). "Modifying" a million-element vector
creates a new vector sharing >99.9% of the structure. This makes immutability practical,
not just theoretical.

**REPL-Driven Development** — Clojure's REPL is not a toy console. Developers evaluate code
in their editor, sending forms directly to a running application. This enables an interactive
feedback loop faster than any compile-run-debug cycle. The REPL connects to a live system
via nREPL, and state persists across evaluations.

**Macros** — as a Lisp, Clojure code is data (lists, vectors, maps). Macros transform code
at compile time, enabling DSLs and language extensions that are impossible in non-homoiconic
languages.

**Multimethods and Protocols** — runtime polymorphism. Multimethods dispatch on arbitrary
functions of the arguments (not just type). Protocols provide type-based dispatch with Java
interface-level performance.

**Transducers** — composable algorithmic transformations decoupled from their input and
output sources. A transducer can be applied to sequences, core.async channels, or custom
data sources without modification.

**Destructuring** — first-class pattern matching on maps, vectors, and nested structures
directly in function arguments and `let` bindings.
```clojure
(defn greet [{:keys [name age] :or {age "unknown"}}]
  (str "Hello " name ", age " age))

(greet {:name "Alice" :age 30}) ;=> "Hello Alice, age 30"
```

**Sequence Abstraction** — a unified interface (first/rest/cons) over lists, vectors, maps,
sets, strings, streams, files, and database results. Most of Clojure's standard library
operates on this abstraction, enabling code reuse across data sources.

## Strengths

1. Concurrency model (atoms, refs, agents, core.async) is unmatched in expressiveness
2. Immutability by default eliminates entire classes of bugs
3. REPL-driven development provides the fastest feedback loop of any compiled-target language
4. Full access to the JVM ecosystem (any Java library works from Clojure)
5. Babashka makes Clojure viable for scripting and CLI (5ms startup)
6. Spec/Malli provide data validation, generative testing, and API docs in one tool
7. Stable language — minimal breaking changes across versions
8. Small, cohesive core — the language fits in your head
9. Nubank's scale proves Clojure works for large, mission-critical systems
10. Homoiconicity enables metaprogramming that other languages cannot match

## Weaknesses

1. JVM startup time (~1-2s) makes it unsuitable for short-lived CLI without Babashka/GraalVM
2. Dynamic typing means many errors surface at runtime
3. Stack traces are notoriously unhelpful (Java exceptions + lazy sequences = confusion)
4. Smaller community and talent pool compared to Java, Python, Go
5. Parentheses and prefix notation are a barrier for newcomers
6. No static type checking by default — large codebases require discipline
7. WASM support is immature
8. GUI ecosystem is limited compared to Java, Rust, or Electron
9. core.async go blocks are not preemptive — easy to accidentally block the thread pool
10. State of Clojure 2025 survey shows declining respondent counts (1,545 in 2025)

## When to Choose Clojure

**Choose Clojure when:**
- Data-intensive applications with complex transformations
- You need robust concurrency without low-level threading code
- Financial services, analytics, or systems requiring immutable audit trails
- Teams that value interactive development (REPL-driven workflow)
- You want JVM performance and ecosystem access with a more expressive language
- Scripting and automation (via Babashka)
- Building DSLs or highly customized abstractions

**Avoid Clojure when:**
- Team has no Lisp/FP experience and timeline is tight
- Short-lived CLI tools (unless using Babashka or GraalVM)
- You need static type safety guarantees (use Rust, Haskell, or OCaml)
- Browser/WASM is a primary target (use Rust or TypeScript)
- Large talent pool is critical for hiring
- GUI-heavy desktop applications
