# Go — Simple, Fast, Concurrent

## Overview

Go (Golang) is a statically typed, compiled language designed at Google by Robert
Griesemer, Rob Pike, and Ken Thompson. First released in 2009, Go prioritizes simplicity,
fast compilation, and built-in concurrency. It compiles to a single static binary with
no external dependencies.

- **Current stable**: ~1.23 (2025/2026)
- **Paradigm**: Imperative, concurrent, with some functional features
- **Typing**: Static, strong, structural (interfaces are implicit)
- **Compilation**: AOT to native code (custom compiler, not LLVM)
- **Package manager**: Go modules (`go mod`)
- **Garbage collector**: Concurrent, tri-color mark-and-sweep (sub-millisecond pauses)

### Design Philosophy
Go deliberately omits features other languages have: no inheritance, no operator
overloading, no exceptions, no macros, no ternary operator, limited generics. This
is a feature, not a bug — Go optimizes for readability and maintainability at scale.

## Type System

### Strengths
- Simple and learnable — few concepts to master
- Structural typing for interfaces — no explicit `implements` keyword
- Generics (since 1.18) — type parameters with constraints
- Strong type safety — no implicit conversions
- Built-in types: slices, maps, channels, functions are all first-class
- Type inference with `:=` (short variable declaration)
- `any` (alias for `interface{}`) — when you need dynamic typing

### Weaknesses
- No sum types / discriminated unions (use interfaces + type switches as workaround)
- No enums (use `const` + `iota`, which is weak compared to Rust/Java enums)
- Generics are limited — no specialization, no variadic type parameters
- No pattern matching (type switches are the closest equivalent)
- Nil is everywhere — nil pointer dereferences are the most common runtime panic
- No immutability enforcement (no `const` for compound types)
- No default values for function parameters
- Interface satisfaction is implicit — can be hard to discover

### Interfaces (Structural Typing)
```go
// Any type with a Read method satisfies io.Reader — no declaration needed
type Reader interface {
    Read(p []byte) (n int, err error)
}

// MyFile satisfies Reader without explicitly saying so
type MyFile struct{ data []byte; pos int }

func (f *MyFile) Read(p []byte) (int, error) {
    n := copy(p, f.data[f.pos:])
    f.pos += n
    return n, nil
}
```

### Generics (Go 1.18+)
```go
func Map[T any, U any](slice []T, fn func(T) U) []U {
    result := make([]U, len(slice))
    for i, v := range slice {
        result[i] = fn(v)
    }
    return result
}

// Type constraints
type Number interface {
    ~int | ~int64 | ~float64
}

func Sum[T Number](values []T) T {
    var total T
    for _, v := range values {
        total += v
    }
    return total
}
```

## Error Handling

Go uses explicit error values. There are NO exceptions. Every function that can fail
returns an `error` as its last return value.

```go
func readFile(path string) ([]byte, error) {
    data, err := os.ReadFile(path)
    if err != nil {
        return nil, fmt.Errorf("reading %s: %w", path, err)
    }
    return data, nil
}

func main() {
    data, err := readFile("config.yaml")
    if err != nil {
        log.Fatal(err) // log and exit
    }
    fmt.Println(string(data))
}
```

### Error Wrapping (Go 1.13+)
```go
// Wrap errors for context
return fmt.Errorf("connecting to database: %w", err)

// Unwrap and check error types
if errors.Is(err, sql.ErrNoRows) {
    // handle not found
}

var pathErr *os.PathError
if errors.As(err, &pathErr) {
    fmt.Println("Failed path:", pathErr.Path)
}
```

### Panic / Recover
`panic` exists for truly exceptional situations (bugs, not expected failures).
`recover` can catch panics but is rarely used outside of framework code.

```go
// This is an anti-pattern — don't use panic for normal error handling
func mustParse(s string) int {
    n, err := strconv.Atoi(s)
    if err != nil {
        panic(fmt.Sprintf("mustParse(%q): %v", s, err))
    }
    return n
}
```

### Common Criticism
The `if err != nil { return err }` pattern is verbose and repetitive. This is Go's
most discussed design tradeoff. The community accepts it as the cost of explicitness.

## Retries

No built-in retry mechanism. Common approaches:

```go
// Simple retry with exponential backoff
func retry(attempts int, sleep time.Duration, fn func() error) error {
    for i := 0; i < attempts; i++ {
        if err := fn(); err == nil {
            return nil
        }
        time.Sleep(sleep)
        sleep *= 2
    }
    return fmt.Errorf("after %d attempts, last error: %w", attempts, fn())
}
```

Libraries:
- **`cenkalti/backoff`** — full-featured exponential backoff
- **`avast/retry-go`** — retry with options pattern
- **`sethvargo/go-retry`** — composable retry with decorators

## Concurrency

Go's concurrency model is CSP (Communicating Sequential Processes). Goroutines are
lightweight green threads (~2KB initial stack, dynamically growing). Channels are typed
conduits for communication between goroutines.

### Goroutines
```go
func main() {
    // Launch 1000 goroutines — trivially cheap
    var wg sync.WaitGroup
    for i := 0; i < 1000; i++ {
        wg.Add(1)
        go func(id int) {
            defer wg.Done()
            process(id)
        }(i)
    }
    wg.Wait()
}
```

### Channels
```go
// Unbuffered channel — synchronous handoff
ch := make(chan string)

go func() {
    ch <- "hello" // blocks until receiver is ready
}()

msg := <-ch // blocks until sender sends

// Buffered channel
ch := make(chan int, 100)

// Select — wait on multiple channels
select {
case msg := <-ch1:
    handle(msg)
case msg := <-ch2:
    handle(msg)
case <-time.After(5 * time.Second):
    log.Println("timeout")
}
```

### Context
```go
ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
defer cancel()

// Pass context through the call chain
result, err := fetchData(ctx, url)

// Check for cancellation
select {
case <-ctx.Done():
    return ctx.Err()
default:
    // continue processing
}
```

### sync Package
- `sync.Mutex` / `sync.RWMutex` — mutual exclusion
- `sync.WaitGroup` — wait for goroutines to complete
- `sync.Once` — exactly-once initialization
- `sync.Map` — concurrent-safe map
- `sync.Pool` — object pooling to reduce GC pressure
- `golang.org/x/sync/errgroup` — goroutine groups with error propagation

### Key Principle
> "Don't communicate by sharing memory; share memory by communicating." — Go Proverb

## Network Protocols

| Protocol    | Package / Library                             | Notes                                |
|-------------|-----------------------------------------------|--------------------------------------|
| HTTP/1.1    | `net/http` (stdlib)                            | Excellent built-in HTTP server/client|
| HTTP/2      | `net/http` (transparent), `golang.org/x/net/http2`| Built into stdlib since Go 1.6  |
| HTTP/3      | `quic-go/quic-go`                              | Full QUIC + HTTP/3 implementation    |
| WebSocket   | `gorilla/websocket`, `nhooyr/websocket`        | Gorilla is most popular              |
| gRPC        | `google.golang.org/grpc`                       | Official gRPC-Go implementation      |
| SSE         | `r3labs/sse`, manual via `net/http`            | Easy to implement manually           |
| Unix Socket | `net.Dial("unix", path)` (stdlib)              | First-class support                  |

### Standard Library HTTP Server
```go
mux := http.NewServeMux()
mux.HandleFunc("GET /api/users/{id}", getUser)
mux.HandleFunc("POST /api/users", createUser)

// Go 1.22+ enhanced routing patterns with method and path params
server := &http.Server{
    Addr:         ":8080",
    Handler:      mux,
    ReadTimeout:  5 * time.Second,
    WriteTimeout: 10 * time.Second,
}
log.Fatal(server.ListenAndServe())
```

## Web Frameworks

### Standard Library (net/http)
Go's standard library HTTP server is production-ready. Many Go developers use it
directly without any framework. Go 1.22 added enhanced routing patterns (method matching,
path parameters), reducing the need for external routers.

### Popular Frameworks/Routers
- **Chi** — lightweight, idiomatic, stdlib-compatible router with middleware
- **Gin** — fast, popular, lots of middleware
- **Echo** — high performance, extensible
- **Fiber** — Express-inspired, built on fasthttp

### Typical Pattern
```go
// Chi example — stdlib-compatible
r := chi.NewRouter()
r.Use(middleware.Logger)
r.Use(middleware.Recoverer)
r.Use(middleware.Timeout(30 * time.Second))

r.Route("/api/v1", func(r chi.Router) {
    r.Get("/users/{id}", getUser)
    r.Post("/users", createUser)
})

http.ListenAndServe(":8080", r)
```

## CLI Tools

### Standard Library (flag)
```go
verbose := flag.Bool("verbose", false, "enable verbose output")
config := flag.String("config", "config.yaml", "config file path")
flag.Parse()
```

### Cobra + Viper (Industry Standard)
```go
var rootCmd = &cobra.Command{
    Use:   "myapp",
    Short: "A great CLI tool",
    Run: func(cmd *cobra.Command, args []string) {
        // root command logic
    },
}

func init() {
    rootCmd.PersistentFlags().StringVar(&cfgFile, "config", "", "config file")
    rootCmd.AddCommand(serveCmd, migrateCmd)
}
```

Used by: Docker CLI, Kubernetes (kubectl), Hugo, GitHub CLI.

## TUI (Terminal User Interface)

### Bubbletea (Charm)
Elm Architecture-inspired TUI framework:

```go
type model struct {
    cursor  int
    choices []string
    selected map[int]struct{}
}

func (m model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
    switch msg := msg.(type) {
    case tea.KeyMsg:
        switch msg.String() {
        case "up", "k":
            m.cursor--
        case "down", "j":
            m.cursor++
        case "enter":
            m.selected[m.cursor] = struct{}{}
        }
    }
    return m, nil
}
```

Charm ecosystem: `bubbletea` (framework), `bubbles` (components), `lipgloss` (styling),
`glamour` (markdown rendering), `huh` (forms), `gum` (scripting-friendly TUI).

## Structured Logging

### slog (Go 1.21+ stdlib)
```go
import "log/slog"

logger := slog.New(slog.NewJSONHandler(os.Stdout, &slog.HandlerOptions{
    Level: slog.LevelInfo,
}))
slog.SetDefault(logger)

slog.Info("request handled",
    slog.String("method", "GET"),
    slog.String("path", "/api/users"),
    slog.Int("status", 200),
    slog.Duration("latency", elapsed),
)
// Output: {"time":"2025-01-15T10:30:00Z","level":"INFO","msg":"request handled","method":"GET","path":"/api/users","status":200,"latency":"1.234ms"}
```

### Other Options
- **zerolog** — zero-allocation JSON logger (fastest)
- **zap** (Uber) — structured, leveled, fast
- Both predate slog; slog is now the standard for new projects

## Prometheus Metrics

Go is Prometheus's native language — the Prometheus server itself is written in Go.

```go
import (
    "github.com/prometheus/client_golang/prometheus"
    "github.com/prometheus/client_golang/prometheus/promhttp"
)

var (
    httpRequests = prometheus.NewCounterVec(
        prometheus.CounterOpts{
            Name: "http_requests_total",
            Help: "Total HTTP requests",
        },
        []string{"method", "path", "status"},
    )
    requestDuration = prometheus.NewHistogramVec(
        prometheus.HistogramOpts{
            Name:    "http_request_duration_seconds",
            Help:    "HTTP request duration",
            Buckets: prometheus.DefBuckets,
        },
        []string{"method", "path"},
    )
)

func init() {
    prometheus.MustRegister(httpRequests, requestDuration)
}

// Expose /metrics endpoint
http.Handle("/metrics", promhttp.Handler())
```

## OpenAPI

- **swaggo/swag** — generate OpenAPI from Go comments/annotations
- **oapi-codegen** — generate Go code FROM OpenAPI specs (recommended approach)
- **kin-openapi** — OpenAPI 3.x parsing and validation
- **go-swagger** — Swagger 2.0 support (older)

```go
// swaggo annotation style
// @Summary      Get user by ID
// @Description  Returns a single user
// @Tags         users
// @Produce      json
// @Param        id   path      int  true  "User ID"
// @Success      200  {object}  User
// @Failure      404  {object}  ErrorResponse
// @Router       /users/{id} [get]
func getUser(w http.ResponseWriter, r *http.Request) { /* ... */ }
```

## Health Checks

Typically simple HTTP endpoints — Go's stdlib makes this trivial:

```go
mux.HandleFunc("GET /healthz", func(w http.ResponseWriter, r *http.Request) {
    w.WriteHeader(http.StatusOK)
    w.Write([]byte("ok"))
})

mux.HandleFunc("GET /readyz", func(w http.ResponseWriter, r *http.Request) {
    if err := db.PingContext(r.Context()); err != nil {
        http.Error(w, "database not ready", http.StatusServiceUnavailable)
        return
    }
    w.WriteHeader(http.StatusOK)
})
```

Libraries: **`heptiolabs/healthcheck`**, **`alexliesenfeld/health`**.

## Container / Cgroups Awareness

- **`uber-go/automaxprocs`** — automatically sets `GOMAXPROCS` to match container CPU quota
  ```go
  import _ "go.uber.org/automaxprocs" // Just import it
  ```
- Without this, Go defaults to host CPU count, which wastes resources in containers
- Go's GC is generally well-behaved in containers
- `GOMEMLIMIT` (Go 1.19+) — set soft memory limit (useful for containers)
  ```bash
  GOMEMLIMIT=512MiB ./myapp
  ```

## Desktop GUI

- **Fyne** — pure Go cross-platform GUI (Material Design-inspired)
- **Gio** — immediate-mode GUI
- **Wails** — Electron alternative (Go backend + web frontend) — similar to Tauri
- **go-gtk**, **gotk4** — GTK bindings
- GUI is not Go's strength — most Go developers use web UIs or TUIs

## WASM Support

```bash
GOOS=js GOARCH=wasm go build -o main.wasm
```

- Compiles Go to WASM, but output is large (~2-15MB) because the Go runtime + GC is included
- `tinygo` produces much smaller WASM binaries (~50-500KB) but doesn't support all of Go
- WASI support via `GOOS=wasip1` (Go 1.21+)
- Not competitive with Rust-WASM for size-sensitive browser use cases

## Fat Binary / Static Distribution

Go produces static binaries by default. This is one of its killer features.

```bash
# Standard build — static binary (if no cgo)
go build -o myapp .

# Explicitly disable cgo for guaranteed static binary
CGO_ENABLED=0 go build -o myapp .

# Cross-compile — just set GOOS and GOARCH
GOOS=linux GOARCH=amd64 go build -o myapp-linux .
GOOS=darwin GOARCH=arm64 go build -o myapp-mac .
GOOS=windows GOARCH=amd64 go build -o myapp.exe .

# Minimal binary (strip debug info)
go build -ldflags="-s -w" -o myapp .
# Typical web service: ~8-15MB (stripped)
```

### GoReleaser
Automates cross-compilation, packaging, and release:
```yaml
# .goreleaser.yaml
builds:
  - goos: [linux, darwin, windows]
    goarch: [amd64, arm64]
```

## Embeddability

- Go can be compiled as a C shared library: `go build -buildmode=c-shared`
- Can call C code via `cgo` (but this breaks static compilation and cross-compilation)
- Not commonly embedded in other languages (unlike Rust or C)
- Go prefers to be the host, not the guest

## Testing

```go
// myapp_test.go — tests live alongside code
func TestSum(t *testing.T) {
    got := Sum(1, 2, 3)
    if got != 6 {
        t.Errorf("Sum(1,2,3) = %d, want 6", got)
    }
}

// Table-driven tests — idiomatic Go
func TestFibonacci(t *testing.T) {
    tests := []struct {
        input int
        want  int
    }{
        {0, 0}, {1, 1}, {2, 1}, {5, 5}, {10, 55},
    }
    for _, tt := range tests {
        t.Run(fmt.Sprintf("fib(%d)", tt.input), func(t *testing.T) {
            got := Fibonacci(tt.input)
            if got != tt.want {
                t.Errorf("got %d, want %d", got, tt.want)
            }
        })
    }
}

// Benchmarks
func BenchmarkFibonacci(b *testing.B) {
    for i := 0; i < b.N; i++ {
        Fibonacci(20)
    }
}
```

```bash
go test ./...                  # Run all tests
go test -race ./...            # With race detector
go test -bench=. ./...         # With benchmarks
go test -cover ./...           # With coverage
go vet ./...                   # Static analysis
```

## Notable Projects Built in Go

- **Docker** — containerization platform
- **Kubernetes** — container orchestration
- **Terraform** — infrastructure as code
- **Hugo** — fastest static site generator
- **Prometheus** — monitoring and alerting
- **CockroachDB** — distributed SQL database
- **etcd** — distributed key-value store (used by Kubernetes)
- **Grafana** — observability dashboards
- **Consul / Vault / Nomad** (HashiCorp) — infrastructure tools
- **Traefik** — cloud-native reverse proxy
- **Caddy** — web server with automatic HTTPS
- **Gitea** — self-hosted Git service
- **Minio** — S3-compatible object storage
- **InfluxDB** — time-series database
- **Syncthing** — continuous file synchronization

## Special Features

- **Fast compilation** — large projects build in seconds, not minutes
- **Built-in concurrency** — goroutines + channels are part of the language, not a library
- **Static binary** — `go build` produces a single file with no dependencies
- **Cross-compilation** — change two env vars, get a binary for any OS/arch
- **`go fmt`** — one true code style, no debates
- **Race detector** — `go test -race` finds data races at runtime
- **Built-in profiling** — `pprof` for CPU, memory, goroutine, block profiling
- **Embed directive** — embed files into the binary at compile time
  ```go
  //go:embed templates/*
  var templates embed.FS
  ```
- **`go generate`** — code generation as part of the build process

## Strengths

1. Simplicity — small language, easy to learn, easy to read
2. Fast compilation — near-instant feedback loop
3. Static binaries — deploy by copying a single file
4. Built-in concurrency primitives (goroutines + channels)
5. Excellent standard library (HTTP server/client, JSON, crypto, testing)
6. Cross-compilation is trivial
7. Go is the language of cloud infrastructure (Docker, K8s, Terraform)
8. Strong backwards compatibility promise (Go 1 compatibility guarantee)
9. Built-in testing, benchmarking, profiling, race detection
10. Garbage collector has sub-millisecond pauses

## Weaknesses

1. Verbose error handling (`if err != nil` everywhere)
2. No sum types / discriminated unions
3. Limited generics (no specialization, no HKTs)
4. No enums (iota constants are a weak substitute)
5. Nil pointer dereferences are still possible and common
6. No immutability enforcement
7. Large WASM binaries (Go runtime + GC included)
8. `cgo` breaks cross-compilation and static linking
9. No operator overloading (matrix/math code is verbose)
10. Package management history was rocky (though Go modules are good now)

## When to Choose Go

**Choose Go when:**
- Building cloud infrastructure, DevOps tools, or platform services
- You need fast compilation and simple deployment (single static binary)
- Team is large and diverse — Go's simplicity aids readability at scale
- Building networked services, APIs, microservices
- You want excellent concurrency without learning complex type systems
- CLI tools that need to be cross-platform
- Projects where Docker, Kubernetes, or cloud-native is the ecosystem

**Avoid Go when:**
- Compute-intensive work needing bare-metal performance (use Rust or C++)
- Complex domain modeling needing algebraic types (use Rust, Haskell, or Elixir)
- GUI applications (use Rust/Tauri, Java/Kotlin, Swift, or Electron)
- Browser/WASM targets where binary size matters (use Rust or Elm)
- Scripting or data science (use Python)
- You need strong guarantees about memory safety without GC (use Rust)
- Highly concurrent fault-tolerant systems (use Elixir/BEAM)
