# Elm

Elm is a purely functional language for building web frontends, created by Evan Czaplicki in 2012. It compiles to JavaScript and guarantees **no runtime exceptions** through its type system. The current stable version is 0.19.1 (October 2019).

## The Elm Architecture (TEA)

Every Elm program follows the same pattern:

```
Model → Update → View

init   : Model                         -- initial state
update : Msg -> Model -> (Model, Cmd)  -- state transitions
view   : Model -> Html Msg             -- render UI
```

- **Model** — the entire application state as an immutable record
- **Msg** — a union type describing every possible event
- **Update** — a pure function: given a message and current model, return new model + side effects
- **View** — a pure function: given the model, return virtual DOM

Side effects (HTTP, time, randomness) are described as `Cmd` values returned from `update`, never executed directly. The runtime handles them and delivers results back as `Msg`.

## Type System

Elm has the **strongest type system** of the four languages in this project. It is the core of the language's value proposition.

### Features
- **Hindley-Milner type inference** — the compiler infers every type automatically. Annotations are optional but encouraged for documentation.
- **Custom types (algebraic data types)** — `type RemoteData = Loading | Success String | Failure Http.Error`. The compiler enforces exhaustive pattern matching — every variant must be handled.
- **No null** — `type Maybe a = Just a | Nothing`. If a value might be absent, the type forces you to handle both cases.
- **No exceptions** — `type Result error value = Ok value | Err error`. All fallible operations return `Result`. There is no `throw`, no `try/catch`, no uncaught exceptions.
- **Extensible records** — `{ a | name : String }` means "any record that has a `name` field". Functions can operate on any record with the right shape.
- **Phantom types** — type parameters that exist only at the type level. Used for compile-time validation (e.g., units of measure, validated strings).
- **Opaque types** — modules can expose a type without exposing its constructor, forcing all creation to go through validated functions.

### Strengths
- **No runtime exceptions. Period.** If it compiles, it runs. No `undefined is not a function`, no null pointer, no unhandled promise rejection. This is Elm's defining guarantee.
- **Exhaustive pattern matching** — the compiler forces you to handle every case. Add a new variant to a custom type and the compiler tells you every place that needs updating.
- **Fearless refactoring** — rename a field, change a type, restructure data — the compiler finds every affected call site. This makes maintaining large Elm codebases remarkably safe.
- **Enforced semantic versioning** — the package manager diffs the public API between versions and enforces semver. A patch release cannot change a function's type.
- **Type-driven development** — define types first, let the compiler guide the implementation. Elm's error messages are famously helpful, often suggesting the fix.

### Weaknesses
- **No typeclasses / traits** — you can't define a generic `map` that works on any container. Each type (List, Maybe, Result, etc.) has its own `map` function. This leads to some code duplication.
- **No higher-kinded types** — you can't abstract over type constructors like `Functor f => f a -> f b`.
- **Limited type-level programming** — no dependent types, no GADTs, no type families. The type system is simple and predictable, which is a trade-off.
- **Record system limitations** — no anonymous record types in pattern matching, no record extension in custom types. This occasionally forces awkward workarounds.

## Error Handling

Elm has **no exceptions**. All error handling is done through types.

### Result Type (primary pattern)
```elm
type Result error value
    = Ok value
    | Err error

-- Example: parsing a string to an int
String.toInt "42"    -- Ok 42
String.toInt "abc"   -- Err "not an int"

-- You must handle both:
case String.toInt input of
    Ok n  -> showNumber n
    Err _ -> showError "please enter a number"
```

### Maybe Type (optional values)
```elm
type Maybe a
    = Just a
    | Nothing

-- Example: looking up a key
Dict.get "name" myDict    -- Maybe String

-- Must handle both:
case Dict.get "name" myDict of
    Just name -> greet name
    Nothing   -> greet "stranger"
```

### Chaining Errors (Result.andThen)
```elm
parseAndValidate : String -> Result String User
parseAndValidate input =
    Json.Decode.decodeString userDecoder input
        |> Result.mapError Json.Decode.errorToString
        |> Result.andThen validateAge
        |> Result.andThen validateEmail
```
This is Elm's equivalent of Elixir's `with` — it short-circuits on the first `Err`.

### HTTP Errors
```elm
type Msg
    = GotResponse (Result Http.Error String)

update msg model =
    case msg of
        GotResponse (Ok body) ->
            ( { model | data = body }, Cmd.none )

        GotResponse (Err Http.Timeout) ->
            ( { model | error = "Request timed out" }, retryCmd )

        GotResponse (Err (Http.BadStatus 404)) ->
            ( { model | error = "Not found" }, Cmd.none )

        GotResponse (Err _) ->
            ( { model | error = "Request failed" }, Cmd.none )
```

### Retry Patterns
Elm handles retries through the architecture, not through special constructs:
```elm
update msg model =
    case msg of
        GotResponse (Err _) ->
            if model.retries < 3 then
                ( { model | retries = model.retries + 1 }
                , Process.sleep 1000 |> Task.perform (\_ -> Retry)
                )
            else
                ( { model | error = "Max retries exceeded" }, Cmd.none )

        Retry ->
            ( model, fetchData model.url )
```

### No Partial Functions
Elm has no `head` that can crash on an empty list. All list operations are total:
```elm
List.head [1, 2, 3]    -- Just 1
List.head []            -- Nothing
```
This means **every** function in Elm's standard library is safe to call with any valid input.

## Language Features

- **Hindley-Milner type inference** — no type annotations required (but encouraged)
- **Custom types (union types)** — `type Shape = Circle Float | Rect Float Float`
- **No null** — `Maybe a = Just a | Nothing`
- **No exceptions** — `Result error value = Ok value | Err error`
- **Records** — `{ name : String, age : Int }` with extensible record types
- **Immutable everything** — all data is immutable; "updates" return new values
- **Compiler-driven development** — error messages guide you to fixes
- **Let expressions** — `let x = 5 in x + 1` for local bindings
- **Case expressions with exhaustiveness checking** — the compiler rejects incomplete matches
- **Automatic currying** — all functions are curried: `add 1 2` and `add 1` (partial application) both work

## Ecosystem

| Tool | Purpose |
|---|---|
| **elm make** | Compiler (Elm → JavaScript) |
| **elm-test** | Test framework with fuzz testing (property-based) |
| **elm-ui** | Layout library replacing CSS (design-oriented, not CSS-oriented) |
| **elm-css** | Typed CSS-in-Elm alternative |
| **elm/http** | HTTP requests as commands |
| **elm/json** | JSON encode/decode with composable decoders |
| **elm/browser** | DOM integration (sandbox, element, document, application) |
| **elm/svg** | SVG rendering |
| **elm/parser** | Parser combinators for custom grammars |
| **elm-review** | Linter with custom rules (AST-based) |

## Network & Protocol Support

Elm runs in the browser, so all network access goes through browser APIs. Elm provides type-safe wrappers:

| Protocol | Elm Support | Notes |
|---|---|---|
| **HTTP/1.1 & HTTP/2** | `elm/http` (`Http.get`, `Http.post`) | Browser handles protocol negotiation transparently. Elm sees `Http.Error` (Timeout, BadStatus, NetworkError). |
| **HTTP/3** | Transparent | If the browser supports QUIC, Elm benefits automatically. No Elm code changes needed. |
| **WebSocket** | **Via ports only** | `elm-lang/websocket` was removed in 0.19. Use JS WebSocket API through ports. Community: `billstclair/elm-websocket-client`. |
| **SSE** | Via ports | JS creates `EventSource`, pushes messages to Elm through port subscriptions. |
| **gRPC** | Via ports (gRPC-web) | Use grpc-web JS client through ports. |
| **Unix sockets** | N/A | Browser environment has no filesystem/socket access. |

### The Ports Pattern for WebSocket

```
-- Elm (ports)
port sendWs : String -> Cmd msg
port receiveWs : (String -> msg) -> Sub msg

-- JavaScript
var ws = new WebSocket("wss://example.com/socket");
app.ports.sendWs.subscribe(function(msg) { ws.send(msg); });
ws.onmessage = function(e) { app.ports.receiveWs.send(e.data); };
```

This pattern applies to any browser API Elm doesn't wrap natively (WebSocket, WebRTC, Web Audio, clipboard, etc.).

## Concurrency Model

Elm has **no threads, no processes, no shared state**. "Concurrency" is achieved through the runtime:

- **`Cmd.batch`** — fire multiple commands (HTTP requests, etc.) simultaneously. The runtime executes them in parallel; results arrive as `Msg` values in any order.
- **`Sub.batch`** — listen to multiple subscriptions (timers, ports, keyboard) at once.
- **`Task`** — chain async operations. `Task.map2`, `Task.sequence` for combining results.
- **`Process.sleep`** — delay before sending a message (used for retry backoff, animations).

There is **no concurrency hazard** because all state transitions go through the single `update` function. This eliminates race conditions by design.

## TTY & Terminal Support

Elm is a **browser-only language** — it has no TTY/terminal support. However:

- Tutorial 03 simulates a command palette in the browser
- Tutorial 04 simulates a terminal UI with a monospace character grid
- `Browser.Events.onKeyDown` handles keyboard input
- CSS `font-family: monospace` + grid layout creates terminal-like UIs
- For actual terminal apps, use Elixir or Erlang with TermUI/Owl

## Container & Server-Side

Elm does **not run on servers or in containers**. It compiles to JavaScript that runs in the browser. For server-side concerns (cgroups, health checks, metrics), pair Elm with a BEAM backend:

- Elm dashboard → polls Elixir's `/healthz`, `/readyz`, `/health` endpoints
- Elm metrics viewer → parses Prometheus text from Elixir's `/metrics`
- Elm frontend → connects to Phoenix Channels via ports for real-time updates

## Special Features

- **JSON Decoders** — Elm's JSON decoding is a composable pipeline of decoder functions, not automatic reflection. This forces you to define the exact shape you expect, catching malformed API responses at the boundary instead of deep in your app. It's more verbose than `JSON.parse()` but vastly safer.
- **Fuzz testing** — elm-test includes property-based testing (fuzzing). Define invariants, and the test runner generates random inputs to find counterexamples.
- **Ports** — the only way to call JavaScript. Elm sends a message out via a port command, JS receives it and can send messages back. This keeps Elm pure — all impurity is quarantined in JS. Ports are typed at the Elm boundary.
- **Managed effects** — HTTP, time, randomness are all managed by the runtime. Your code only describes *what* to do, never *how*. This makes every `update` function testable as a pure function.
- **Debug.todo** — a placeholder that type-checks as any type. Lets you sketch out code top-down, with the compiler guiding you to fill in the holes.
- **Compiler error messages** — legendary for quality. They include the specific mismatch, the expected vs actual type, and often a suggestion for how to fix it.
- **Dead code elimination** — the compiler removes all unused code from the output JS bundle. This is why Elm bundles are 20-50 KB gzipped despite including a virtual DOM runtime.
- **No runtime dependencies** — Elm compiles to a single JS file with zero npm dependencies. No bundler, no webpack, no node_modules.

## Integration with Phoenix/BEAM

Elm frontends pair well with Phoenix backends via:

- **Flags** — pass initial data from Phoenix templates to Elm at startup
- **Ports** — bidirectional message channel between Elm and JavaScript (and thus Phoenix channels)
- **Custom Elements** — wrap Elm apps as web components

```
Phoenix Template → Elm.Main.init({ flags: @json_data })
Elm port out     → JS → Phoenix Channel push
Phoenix push     → JS → Elm port in
```

This gives you: type-safe frontend (Elm) + fault-tolerant backend (Elixir/Phoenix) + real-time via channels.

## Distribution & Fat Binary Options

Elm compiles to a **single JavaScript file** with zero npm dependencies.

### Web deployment
Serve `main.js` + `index.html` from any static host (CDN, S3, Netlify, GitHub Pages). Typical gzipped size: 20-50 KB. This is the simplest and most common option.

### Desktop fat binaries (single executable)

| Framework | Binary Size | Self-Contained? | Notes |
|---|---|---|---|
| **Tauri** (recommended) | 3-10 MB | Yes (uses OS WebView) | Rust backend. Produces `.dmg`, `.msi`, `.AppImage`, `.deb`, `.rpm`. Template: `elm-land/tauri`. |
| **Wails** | ~4 MB | Yes (uses OS WebView) | Go backend. Dedicated Elm template with hot-reload: `benjamin-thomas/wails-elm-template`. |
| **Electron** | 100-300 MB | Yes (bundles Chromium) | Works but bloated. Not recommended for new projects. |
| **Neutralinojs** | ~2 MB | Mostly (needs `resources.neu` file) | Lightest option. Single-file mode incomplete (RFC exists). |
| **Gluon** | <1 MB | No (needs system browser) | Extremely light but not truly self-contained. |

**Recommendation**: Tauri for production apps (smallest self-contained binary, best installer support, Tauri 2.x supports mobile). Wails if you prefer Go over Rust.

### PWA
Elm apps can be wrapped as Progressive Web Apps with a service worker for offline use. No native binary needed.

### WASM Support

Elm compiles to JavaScript only. **No WASM backend exists.**
- **elm_c_wasm** — experimental proof-of-concept compiling Elm's pure core to C → WASM via Emscripten. Effects stay in JS. Not production-ready.
- **Core blocker**: WASM historically lacked GC and closures. The WASM GC proposal is progressing, but Elm has not committed to targeting it.

### Tcl/Tk & Desktop Native UI

Not applicable. Elm runs in the browser only. For desktop apps, use Elm + Tauri. For native system UIs (Tcl/Tk, wxWidgets, GTK, etc.), use Elixir or Erlang.

## Notable Software Built with Elm

| Project | Description |
|---|---|
| **NoRedInk** | EdTech platform. Largest known Elm codebase (~250k lines, 1500+ files). Zero runtime exceptions since 2015. Elm creator Evan Czaplicki works here. |
| **Vendr** | SaaS purchasing platform ($1B+ valuation). Bet on Elm at scale. |
| **Concourse CI** | Container-based CI/CD system (originally Pivotal/VMware). Dashboard built in Elm. |
| **Microsoft** | Customer support system frontend (since 2016). |
| **Brilliant.org** | Interactive STEM learning platform. Math/science exercises written in Elm. |
| **Pivotal Tracker** | Agile project management tool. Elm in production frontend. |
| **Culture Amp** | Employee analytics platform. Used Elm 2016-2020 with zero runtime errors. Later migrated to TypeScript/React for ecosystem reasons, not language quality. |
| **Ford Motor Company** | Production Elm usage (details not public). |
| **Gizra** | Web agency contributing significant Elm open-source packages. |

## Strengths

- **No runtime exceptions** — if it compiles, it won't crash in the browser
- **Fearless refactoring** — the compiler catches every breakage; rename a field and fix all 47 call sites
- **Small bundle size** — typically 20-50 KB gzipped for a full application
- **Fast rendering** — virtual DOM with aggressive optimizations
- **Enforced semantic versioning** — the package manager diffs APIs and enforces semver
- **Total functions** — no partial functions in the standard library; every function is safe to call
- **Reproducible builds** — exact package resolution, no lock file drift
- **Zero dependencies** — compiled output is a single JS file. No node_modules, no bundler, no runtime deps.

## Weaknesses

- **Stalled releases** — 0.19.1 is from 2019; the community maintains the ecosystem but no new language features
- **JS interop only via ports** — no FFI; calling JavaScript requires message passing through ports. This makes some integrations (Web Audio, Canvas, WebGL) verbose.
- **No server-side rendering** — Elm only runs in the browser
- **No WASM target** — cannot escape the JavaScript ecosystem
- **Smaller ecosystem** — fewer packages than React/Vue; some things require ports to JS libraries
- **Learning curve** — ML-family syntax and functional patterns unfamiliar to most web developers
- **No typeclasses** — code duplication for generic operations across different container types
- **Benevolent dictatorship** — language evolution is controlled by a single maintainer, which ensures quality but limits pace and community influence
- **Verbose JSON decoding** — safe but requires more code than auto-derived decoders in Haskell/Rust

## When to Choose Elm

- **Mission-critical UIs** — healthcare, finance, where a frontend crash has consequences
- **Long-lived applications** — Elm apps are easy to maintain and refactor over years
- **Teams that value correctness** — trading initial velocity for zero runtime errors
- **Paired with Phoenix** — the Elm Architecture mirrors LiveView's model, making the mental model consistent across stack
- **Complex UI state** — the enforced architecture prevents state management from becoming chaotic
