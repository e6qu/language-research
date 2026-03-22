# Java — Enterprise-Grade, JVM-Powered

## Overview

Java is a class-based, object-oriented programming language designed to have as few
implementation dependencies as possible. Created by James Gosling at Sun Microsystems
(1995), now owned by Oracle. Java runs on the JVM (Java Virtual Machine), which provides
platform independence ("write once, run anywhere"), sophisticated garbage collection,
and JIT (Just-In-Time) compilation.

- **Current**: Java 21 LTS (2023), Java 22-24 (short-term), Java 25 LTS (Sept 2025)
- **Paradigm**: Object-oriented, imperative, functional (since Java 8), concurrent
- **Typing**: Static, strong, nominal
- **Compilation**: Source -> bytecode (javac) -> JIT compiled to native at runtime
- **Package managers**: Maven (XML), Gradle (Groovy/Kotlin DSL)
- **Editions**: SE (Standard), EE (Enterprise, now Jakarta EE)

### Modern Java (21+) is Not Your Parents' Java
Java has evolved dramatically since Java 8. Modern Java includes: records, sealed classes,
pattern matching, virtual threads, text blocks, switch expressions, and local variable
type inference (`var`). It is a significantly better language than the Java of 2014.

## Type System

### Strengths
- **Records** (Java 16+) — immutable data classes with minimal boilerplate
  ```java
  record Point(double x, double y) {}
  // Auto-generates: constructor, equals, hashCode, toString, accessors
  ```
- **Sealed classes** (Java 17+) — restricted class hierarchies (algebraic types)
  ```java
  sealed interface Shape permits Circle, Rectangle, Triangle {}
  record Circle(double radius) implements Shape {}
  record Rectangle(double w, double h) implements Shape {}
  record Triangle(double a, double b, double c) implements Shape {}
  ```
- **Pattern matching** (Java 21+) — exhaustive matching on sealed types
  ```java
  double area(Shape s) {
      return switch (s) {
          case Circle c -> Math.PI * c.radius() * c.radius();
          case Rectangle r -> r.w() * r.h();
          case Triangle t -> heronsFormula(t);
      };
  }
  ```
- **Generics** — full parametric polymorphism (with type erasure)
- **Annotations** — powerful metadata system (used by frameworks extensively)
- **Null safety** — `Optional<T>` (Java 8+), though null is still pervasive

### Weaknesses
- Null is everywhere — `NullPointerException` remains the most common error
- Type erasure means generics are less powerful at runtime (`List<String>` becomes `List`)
- No value types (yet) — Project Valhalla aims to fix this
- No union types or discriminated unions (sealed classes are a partial solution)
- Verbose compared to Kotlin, Scala, or modern languages (improving but still wordy)
- No unsigned integer types
- Arrays are covariant (type-unsound: `String[]` is a `Object[]`)
- Checked exceptions are controversial and often poorly used

## Error Handling

Java uses exceptions (checked and unchecked):

```java
// Checked exception — must be declared or caught
public String readFile(Path path) throws IOException {
    return Files.readString(path);
}

// Try-with-resources (auto-closeable)
try (var reader = Files.newBufferedReader(path)) {
    return reader.readLine();
} catch (FileNotFoundException e) {
    logger.warn("File not found: {}", path, e);
    return defaultValue;
} catch (IOException e) {
    throw new UncheckedIOException(e);
}
```

### Modern Patterns
```java
// Optional for nullable returns (avoid returning null)
public Optional<User> findUser(long id) {
    return Optional.ofNullable(userMap.get(id));
}

// Result pattern (not built-in but common)
// Using sealed interfaces to create Result type
sealed interface Result<T> permits Success, Failure {}
record Success<T>(T value) implements Result<T> {}
record Failure<T>(Exception error) implements Result<T> {}
```

### Key Difference from Go/Rust
Java's exceptions unwind the stack automatically. You do not need to check errors at every
call site. This is convenient but can hide error paths and lead to swallowed exceptions.

## Retries

### Resilience4j (Standard for Java)
```java
RetryConfig config = RetryConfig.custom()
    .maxAttempts(3)
    .waitDuration(Duration.ofMillis(500))
    .retryOnException(e -> e instanceof IOException)
    .exponentialBackoff(2, Duration.ofSeconds(10))
    .build();

Retry retry = Retry.of("myService", config);

Supplier<String> decorated = Retry.decorateSupplier(retry, () -> callExternalService());
String result = decorated.get();
```

Also: **Spring Retry**, **Failsafe**, **MicroProfile Fault Tolerance**.

## Concurrency

### Virtual Threads (Java 21+) — Game Changer
Virtual threads are lightweight threads managed by the JVM, similar to goroutines.
One million virtual threads use ~1GB RAM vs one million OS threads being impossible.

```java
// Create a virtual thread
Thread.startVirtualThread(() -> {
    var result = blockingHttpCall();
    process(result);
});

// ExecutorService with virtual threads
try (var executor = Executors.newVirtualThreadPerTaskExecutor()) {
    // Submit 100,000 tasks — each gets its own virtual thread
    var futures = IntStream.range(0, 100_000)
        .mapToObj(i -> executor.submit(() -> fetchData(i)))
        .toList();

    for (var future : futures) {
        process(future.get());
    }
}
```

### Structured Concurrency (Preview in Java 21+)
```java
try (var scope = new StructuredTaskScope.ShutdownOnFailure()) {
    Subtask<User> user = scope.fork(() -> fetchUser(id));
    Subtask<Order> order = scope.fork(() -> fetchOrder(id));

    scope.join();           // Wait for both
    scope.throwIfFailed();  // Propagate errors

    return new UserOrder(user.get(), order.get());
}
```

### CompletableFuture (Async/Non-blocking)
```java
CompletableFuture<String> future = CompletableFuture
    .supplyAsync(() -> fetchData(url))
    .thenApply(data -> parse(data))
    .thenCompose(parsed -> enrichAsync(parsed))
    .exceptionally(ex -> {
        logger.error("Pipeline failed", ex);
        return fallbackValue;
    });
```

### Stream API (Parallel Data Processing)
```java
List<String> results = users.parallelStream()
    .filter(u -> u.age() > 18)
    .map(User::name)
    .sorted()
    .toList();
```

### Classic Concurrency
- `synchronized` keyword and `Lock` interface
- `java.util.concurrent` — thread pools, concurrent collections, atomic variables
- `ConcurrentHashMap`, `BlockingQueue`, `CountDownLatch`, `Semaphore`

## Network Protocols

| Protocol    | Library / Framework                           | Notes                                |
|-------------|-----------------------------------------------|--------------------------------------|
| HTTP/1.1    | `java.net.http.HttpClient` (Java 11+)         | Built-in, modern, async-capable      |
| HTTP/2      | `java.net.http.HttpClient` (built-in)          | Transparent HTTP/2 support           |
| HTTP/3      | Jetty, Netty (via quiche/ngtcp2)               | Growing support                      |
| WebSocket   | `java.net.http.WebSocket`, Jetty, Tyrus        | Built-in since Java 11               |
| gRPC        | `grpc-java` (official)                          | Protobuf-based, high performance     |
| SSE         | Spring WebFlux, JAX-RS SseEventSource           | Well supported in frameworks         |
| Unix Socket | `java.net.UnixDomainSocketAddress` (Java 16+)  | Built-in                             |

```java
// Modern HTTP client (Java 11+)
var client = HttpClient.newBuilder()
    .version(HttpClient.Version.HTTP_2)
    .connectTimeout(Duration.ofSeconds(10))
    .build();

var request = HttpRequest.newBuilder()
    .uri(URI.create("https://api.example.com/data"))
    .header("Accept", "application/json")
    .GET()
    .build();

// Synchronous
HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());

// Asynchronous
client.sendAsync(request, HttpResponse.BodyHandlers.ofString())
    .thenApply(HttpResponse::body)
    .thenAccept(System.out::println);
```

## Web Frameworks

### Spring Boot (Dominant)
See [JAVA_SPRINGBOOT.md](JAVA_SPRINGBOOT.md) for comprehensive coverage.

### Quarkus
See [JAVA_QUARKUS.md](JAVA_QUARKUS.md) for comprehensive coverage.

### Other Frameworks
- **Micronaut** — compile-time DI, GraalVM native, low memory
- **Helidon** (Oracle) — microservices framework, MicroProfile support
- **Vert.x** (Eclipse) — reactive, event-driven, polyglot
- **Javalin** — lightweight, Kotlin-friendly (like Go's net/http in spirit)
- **Dropwizard** — production-ready, opinionated REST framework

## CLI Tools

### Picocli (Standard for Java CLI)
```java
@Command(name = "myapp", mixinStandardHelpOptions = true, version = "1.0")
class MyApp implements Callable<Integer> {

    @Option(names = {"-v", "--verbose"}, description = "Verbose output")
    boolean verbose;

    @Parameters(index = "0", description = "Input file")
    File inputFile;

    @Override
    public Integer call() {
        // CLI logic here
        return 0;
    }

    public static void main(String[] args) {
        int exitCode = new CommandLine(new MyApp()).execute(args);
        System.exit(exitCode);
    }
}
```

### JBang
Run Java source files as scripts without project setup:
```bash
//usr/bin/env jbang "$0" "$@" ; exit $?
//DEPS com.google.code.gson:gson:2.10

import com.google.gson.Gson;
public class script {
    public static void main(String[] args) {
        var gson = new Gson();
        System.out.println(gson.toJson(Map.of("hello", "world")));
    }
}
```

## TUI (Terminal User Interface)

- **Lanterna** — ncurses-like TUI library for Java
- **JLine** — line reader with completion (used by many REPLs)
- **Texel** — newer TUI framework
- TUI is not a strength of Java — most Java developers use web UIs or desktop GUIs

## Structured Logging

### SLF4J + Logback (Standard)
```java
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

private static final Logger logger = LoggerFactory.getLogger(UserService.class);

logger.info("User created", kv("userId", user.id()), kv("email", user.email()));
// With structured logging (logstash-logback-encoder):
// {"timestamp":"2025-01-15T10:30:00Z","level":"INFO","message":"User created","userId":42,"email":"user@example.com"}
```

### Structured Arguments
```xml
<!-- logback.xml with JSON output -->
<encoder class="net.logstash.logback.encoder.LogstashEncoder"/>
```

### Log4j2
Alternative to Logback, with async logging support and lower latency.

## Prometheus Metrics

### Micrometer (Standard Metrics Facade)
```java
@Autowired
MeterRegistry registry;

Counter requests = registry.counter("http.requests", "method", "GET", "path", "/api/users");
Timer timer = registry.timer("http.request.duration", "method", "GET");

timer.record(() -> {
    handleRequest();
    requests.increment();
});
```

Micrometer supports: Prometheus, Datadog, New Relic, InfluxDB, Graphite, CloudWatch.

### Direct Prometheus Client
```java
import io.prometheus.client.Counter;
import io.prometheus.client.Histogram;

static final Counter requests = Counter.build()
    .name("http_requests_total")
    .help("Total HTTP requests")
    .labelNames("method", "path")
    .register();
```

## OpenAPI

### springdoc-openapi (for Spring Boot)
```java
@Operation(summary = "Get user by ID")
@ApiResponses({
    @ApiResponse(responseCode = "200", description = "User found",
        content = @Content(schema = @Schema(implementation = User.class))),
    @ApiResponse(responseCode = "404", description = "User not found")
})
@GetMapping("/users/{id}")
public ResponseEntity<User> getUser(@PathVariable long id) { /* ... */ }
```

### OpenAPI Generator
Generate Java client/server code from OpenAPI specs (supports Spring, JAX-RS, etc.).

## Health Checks

### Spring Boot Actuator
```yaml
# application.yml
management:
  endpoints:
    web:
      exposure:
        include: health, info, metrics, prometheus
  endpoint:
    health:
      show-details: always
```

Automatic health checks for: database, disk space, Redis, RabbitMQ, Kafka, mail server.

### MicroProfile Health
```java
@Liveness
@ApplicationScoped
public class LivenessCheck implements HealthCheck {
    @Override
    public HealthCheckResponse call() {
        return HealthCheckResponse.up("alive");
    }
}
```

## Container / Cgroups Awareness

- JVM is fully cgroup-aware since Java 10+ (reads container CPU/memory limits)
- JVM auto-sizes heap, thread pools, and GC based on container limits
- `-XX:MaxRAMPercentage=75.0` — use 75% of container memory for heap
- `-XX:ActiveProcessorCount=2` — override detected CPU count
- **JVM ergonomics** automatically tunes GC, heap size, and compiler based on environment
- Container-optimized base images: `eclipse-temurin`, `amazoncorretto`, `bellsoft/liberica`

### Container Best Practices
```dockerfile
FROM eclipse-temurin:21-jre-alpine
COPY target/app.jar /app.jar
ENV JAVA_OPTS="-XX:MaxRAMPercentage=75.0 -XX:+UseZGC"
ENTRYPOINT ["java", "-jar", "/app.jar"]
```

## Desktop GUI

- **JavaFX** — modern UI toolkit (successor to Swing)
- **Swing** — mature, built into JDK (dated look, still widely used in enterprise)
- **SWT** (Eclipse) — native-look widgets
- **Compose Multiplatform** (JetBrains) — Kotlin-based, modern declarative UI
- Java has strong desktop GUI heritage — more options than most languages

## WASM Support

- **TeaVM** — compile Java bytecode to JavaScript or WASM (ahead-of-time)
- **CheerpJ** — run JVM bytecode in the browser via WASM
- **GraalWasm** — run WASM modules inside GraalVM
- **Bytecoder** — Java to WASM/JS compiler
- WASM support is experimental/niche compared to Rust or Go
- Not a primary target for the Java ecosystem

## Fat Binary / Distribution

### Fat JARs (Uber JARs)
```bash
# Maven shade plugin or Spring Boot plugin
mvn package
java -jar target/myapp.jar
# Typical size: 20-80MB (includes all dependencies)
```

### jlink (Custom JRE, Java 9+)
```bash
# Create a minimal JRE with only needed modules
jlink --module-path $JAVA_HOME/jmods \
      --add-modules java.base,java.net.http,java.sql \
      --output custom-jre \
      --strip-debug --no-header-files --no-man-pages
# Result: ~30-50MB custom JRE (vs ~300MB full JDK)
```

### GraalVM Native Image
```bash
# Compile to a native binary — no JVM needed at runtime
native-image -jar myapp.jar -o myapp
# Result: single binary, ~20-80MB
# Startup: milliseconds instead of seconds
# Memory: ~50-80% less than JVM mode
```

Tradeoffs of native image:
- Slower peak throughput (no JIT optimization at runtime)
- Reflection requires configuration
- Not all libraries are compatible (improving rapidly)
- Longer build times (2-10 minutes)

### jpackage (Java 16+)
```bash
# Create platform-specific installer (DMG, MSI, DEB, RPM)
jpackage --input target/ --main-jar myapp.jar --name MyApp --type dmg
```

## Embeddability

- **GraalVM polyglot** — embed Java in other languages and vice versa
- **JNI (Java Native Interface)** — call C/C++ from Java and Java from C/C++
- **JNA (Java Native Access)** — simpler FFI without writing C
- **Panama (Foreign Function & Memory API, Java 22+)** — modern FFI replacement for JNI
- Java is typically the host platform, not embedded in others

## JVM Internals

### JIT Compilation
- **C1 (client)** — fast compilation, moderate optimization (startup)
- **C2 (server)** — slower compilation, aggressive optimization (peak throughput)
- **Tiered compilation** — uses both: C1 first, then C2 for hot methods
- **GraalVM JIT** — alternative JIT compiler written in Java, better for some workloads

### Garbage Collectors
- **G1 (default since Java 9)** — balanced latency/throughput, good for most workloads
- **ZGC (production since Java 15)** — sub-millisecond pauses (< 1ms), scales to TB heaps
- **Shenandoah** — concurrent GC, low-pause (Red Hat)
- **Parallel GC** — maximize throughput, longer pauses acceptable
- **Epsilon** — no-op GC (for benchmarks and very short-lived processes)

```bash
# Use ZGC for low-latency applications
java -XX:+UseZGC -XX:+ZGenerational -jar myapp.jar
```

## Build Tools

### Maven
```xml
<project>
    <groupId>com.example</groupId>
    <artifactId>myapp</artifactId>
    <version>1.0.0</version>
    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
            <version>3.3.0</version>
        </dependency>
    </dependencies>
</project>
```

### Gradle (Kotlin DSL)
```kotlin
plugins {
    id("java")
    id("org.springframework.boot") version "3.3.0"
}

dependencies {
    implementation("org.springframework.boot:spring-boot-starter-web")
    testImplementation("org.springframework.boot:spring-boot-starter-test")
}
```

## Testing

### JUnit 5
```java
@Test
void shouldCalculateArea() {
    var circle = new Circle(5.0);
    assertEquals(78.54, circle.area(), 0.01);
}

@ParameterizedTest
@CsvSource({"1, 3.14", "2, 12.57", "5, 78.54"})
void shouldCalculateAreaParameterized(double radius, double expected) {
    assertEquals(expected, new Circle(radius).area(), 0.01);
}

@Test
void shouldThrowOnNegativeRadius() {
    assertThrows(IllegalArgumentException.class, () -> new Circle(-1));
}
```

### Ecosystem
- **Mockito** — mocking framework
- **AssertJ** — fluent assertions
- **Testcontainers** — Docker-based integration tests
- **ArchUnit** — architecture testing (package dependencies, naming conventions)
- **JMH** — Java Microbenchmark Harness

## Notable Projects Built in Java

- **Android** — Android apps (Java/Kotlin), Android OS core
- **Spring Framework** — dominant enterprise framework
- **Hadoop / Spark** — big data processing
- **Elasticsearch** — search and analytics engine
- **Kafka** — distributed streaming platform
- **Minecraft** — world's best-selling game
- **Jenkins** — CI/CD automation
- **Cassandra** — distributed NoSQL database
- **Neo4j** — graph database
- **IntelliJ IDEA / Eclipse** — IDEs written in Java
- **Keycloak** — identity and access management
- **Gradle** — build tool (written in Java/Groovy)

## Special Features

- **Virtual threads** (Java 21+) — goroutine-like concurrency without changing APIs
- **Pattern matching** — evolving toward full algebraic data type support
- **JVM ecosystem** — Kotlin, Scala, Clojure, Groovy all run on the JVM
- **Backwards compatibility** — Java code from 1996 still compiles and runs
- **Mature profiling** — JFR (Java Flight Recorder), JMC, async-profiler
- **Security** — SecurityManager, strong crypto, TLS, mature security audit history
- **Tooling** — IntelliJ IDEA, Eclipse, VS Code with extensions

## Strengths

1. Massive ecosystem — libraries exist for virtually everything
2. JVM performance is excellent after warmup (JIT optimizes hot paths)
3. Virtual threads make high-concurrency simple (Java 21+)
4. GC options are world-class (ZGC: sub-ms pauses at TB scale)
5. Strong backwards compatibility — code written 20 years ago still works
6. Enormous talent pool — one of the most widely known languages
7. Enterprise adoption — banks, governments, large enterprises rely on Java
8. Modern Java (21+) is genuinely pleasant to write (records, pattern matching, etc.)
9. GraalVM native image enables fast startup and low memory
10. Mature tooling, IDEs, profilers, debuggers

## Weaknesses

1. Verbose syntax (better with modern Java, but still more than Kotlin/Go)
2. Slow startup time in JVM mode (mitigated by GraalVM native image)
3. High memory usage in JVM mode (mitigated by GraalVM or jlink)
4. Null safety is opt-in (Optional exists but null persists everywhere)
5. Checked exceptions are widely considered a design mistake
6. Complex build tooling (Maven XML, Gradle build scripts can be opaque)
7. Framework-heavy culture — Spring "magic" can be hard to debug
8. No operator overloading (math/science code is verbose)
9. WASM support is immature
10. Single-binary distribution requires GraalVM (not the default path)

## When to Choose Java

**Choose Java when:**
- Building enterprise applications with complex business logic
- Team already knows Java / JVM ecosystem
- You need virtual threads for high-concurrency I/O (Java 21+)
- Integrating with existing Java/JVM systems (Kafka, Elasticsearch, Hadoop)
- GraalVM native image meets your startup/memory requirements
- Building Android applications (Java or Kotlin)
- Long-term maintenance is a priority (Java's stability is unmatched)

**Avoid Java when:**
- Simple CLI tools or scripts (too much boilerplate — use Go or Python)
- Systems programming requiring manual memory control (use Rust or C)
- Small microservices where startup time matters and GraalVM is not an option
- Browser/WASM targets (use Rust, Elm, or JavaScript)
- Rapid prototyping (Python, Ruby, or Elixir are faster to iterate with)
- You want a single static binary without GraalVM complexity (use Go or Rust)
