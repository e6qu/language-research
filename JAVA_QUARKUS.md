# Quarkus — Supersonic Subatomic Java

## Overview

Quarkus is a Kubernetes-native Java framework designed for GraalVM native images and
OpenJDK HotSpot. Created by Red Hat, Quarkus moves as much work as possible from runtime
to build time, resulting in dramatically faster startup and lower memory consumption.

- **Current stable**: Quarkus 3.x (2025)
- **Requires**: Java 17+ (21 recommended)
- **Created by**: Red Hat
- **First release**: 2019
- **Tagline**: "Supersonic Subatomic Java"
- **Market position**: #2 Java framework, fastest growing, ~10-15% of new Java projects

### Design Philosophy
Quarkus was built from the ground up for containers and Kubernetes. Traditional Java
frameworks (Spring) were designed for monolithic apps running on application servers.
Quarkus assumes you're building microservices deployed in containers, and optimizes for
that reality: fast startup, low memory, small container images.

## Build-Time DI (ArC)

ArC is Quarkus's CDI-compatible dependency injection container. Unlike Spring (which uses
runtime reflection), ArC resolves all injection at build time.

```java
@ApplicationScoped
public class UserService {

    private final UserRepository repository;
    private final EventBus eventBus;

    @Inject  // Constructor injection
    public UserService(UserRepository repository, EventBus eventBus) {
        this.repository = repository;
        this.eventBus = eventBus;
    }

    public User create(CreateUserRequest request) {
        User user = repository.persist(request.toEntity());
        eventBus.publish("user.created", user);
        return user;
    }
}
```

### How Build-Time DI Works
1. At build time, Quarkus scans all CDI beans and annotations
2. Generates optimized bytecode for bean instantiation and injection
3. Eliminates reflection-based bean discovery at runtime
4. Dead code elimination — unused beans are removed from the native binary
5. Build-time validation — missing injection points are compile errors, not runtime errors

### Benefits over Runtime DI
- **Startup**: No classpath scanning or reflection at boot time
- **Memory**: No reflection metadata kept in memory
- **Native**: Works seamlessly with GraalVM (no reflection configuration needed)
- **Safety**: Injection errors caught at build time, not in production

## Native Compilation via GraalVM

Quarkus has first-class GraalVM native image support — this is its primary differentiator.

```bash
# Build native binary
./mvnw package -Dnative

# Or with Gradle
./gradlew build -Dquarkus.native.enabled=true

# Build native in a container (no local GraalVM needed)
./mvnw package -Dnative -Dquarkus.native.container-build=true
```

### Binary Sizes and Performance

| Mode                    | Binary/Package Size | Startup Time  | Memory (RSS)   |
|-------------------------|---------------------|---------------|----------------|
| JVM (uber-jar)          | ~30MB              | 0.5-2 seconds | 100-200MB      |
| Native binary           | ~20-50MB           | 10-50ms       | 20-50MB        |
| Native container image  | ~5MB (distroless)  | 10-50ms       | 20-50MB        |

### Native Container Image
```bash
# Build a minimal container image with the native binary
./mvnw package -Dnative -Dquarkus.native.container-build=true \
    -Dquarkus.container-image.build=true
```

```dockerfile
# Multi-stage Dockerfile for native build
FROM quay.io/quarkus/ubi-quarkus-mandrel-builder-image:jdk-21 AS build
COPY --chown=quarkus:quarkus . /code
WORKDIR /code
RUN ./mvnw package -Dnative

FROM quay.io/quarkus/quarkus-micro-image:2.0
COPY --from=build /code/target/*-runner /application
EXPOSE 8080
ENTRYPOINT ["./application", "-Dquarkus.http.host=0.0.0.0"]
# Final image: ~50MB total, ~5MB application layer
```

### Native Image Tradeoffs
- No JIT compilation — peak throughput is lower than JVM mode (10-20% typically)
- Build time is long (2-10 minutes)
- Some Java features require configuration (reflection, dynamic proxies)
- Quarkus extensions handle most configuration automatically
- For long-running services, JVM mode may have better sustained throughput

## Vert.x / Mutiny (Reactive)

Quarkus uses Eclipse Vert.x as its underlying reactive engine and Mutiny as its
reactive programming API.

### Mutiny
```java
@Path("/users")
public class UserResource {

    @Inject UserRepository repository;

    @GET
    @Path("/{id}")
    public Uni<User> getUser(@PathParam("id") long id) {
        return repository.findById(id)
            .onItem().ifNull().failWith(() ->
                new NotFoundException("User not found: " + id));
    }

    @GET
    public Multi<User> streamUsers() {
        return repository.streamAll();
    }

    @POST
    public Uni<Response> createUser(CreateUserRequest request) {
        return repository.persist(request.toEntity())
            .onItem().transform(user ->
                Response.created(URI.create("/users/" + user.id)).entity(user).build());
    }
}
```

### Mutiny vs Project Reactor (Spring WebFlux)
| Mutiny              | Project Reactor          |
|---------------------|--------------------------|
| `Uni<T>` (0 or 1)  | `Mono<T>` (0 or 1)      |
| `Multi<T>` (0..N)  | `Flux<T>` (0..N)        |
| Event-driven API    | Operator chain API       |
| Simpler to learn    | More operators available |
| Vert.x integration  | Netty integration        |

### Imperative + Reactive Mix
Quarkus uniquely supports mixing imperative and reactive code in the same application:

```java
@Path("/orders")
public class OrderResource {

    @Inject UserService userService;       // Imperative service
    @Inject PaymentClient paymentClient;   // Reactive client

    @POST
    public Uni<Order> createOrder(OrderRequest request) {
        // Mix imperative and reactive seamlessly
        User user = userService.findById(request.userId());  // Blocking call
        return paymentClient.charge(user, request.amount())   // Non-blocking
            .onItem().transform(payment -> new Order(user, payment));
    }
}
```

## MicroProfile

Quarkus implements Eclipse MicroProfile specifications, providing standardized APIs
for microservices concerns.

### MicroProfile Health
```java
@Liveness
@ApplicationScoped
public class LivenessCheck implements HealthCheck {
    @Override
    public HealthCheckResponse call() {
        return HealthCheckResponse.up("Application is alive");
    }
}

@Readiness
@ApplicationScoped
public class ReadinessCheck implements HealthCheck {

    @Inject DataSource dataSource;

    @Override
    public HealthCheckResponse call() {
        try (Connection conn = dataSource.getConnection()) {
            return HealthCheckResponse.up("Database connection OK");
        } catch (SQLException e) {
            return HealthCheckResponse.down("Database connection failed");
        }
    }
}
```

Endpoints:
- `/q/health` — combined health status
- `/q/health/live` — liveness checks
- `/q/health/ready` — readiness checks
- `/q/health/started` — startup checks

### MicroProfile Metrics
```java
@ApplicationScoped
public class OrderService {

    @Counted(name = "orders_created_total", description = "Total orders created")
    @Timed(name = "order_creation_duration", description = "Order creation time")
    public Order createOrder(OrderRequest request) {
        // Business logic
        return order;
    }

    @Gauge(name = "pending_orders", description = "Current pending orders")
    public long getPendingOrderCount() {
        return orderRepository.countPending();
    }
}
```

Quarkus also supports Micrometer (same as Spring Boot) for broader metrics compatibility.

### MicroProfile OpenAPI
```java
@Path("/users")
@Tag(name = "Users", description = "User management")
public class UserResource {

    @GET
    @Path("/{id}")
    @Operation(summary = "Get user by ID")
    @APIResponse(responseCode = "200", description = "User found",
        content = @Content(schema = @Schema(implementation = User.class)))
    @APIResponse(responseCode = "404", description = "User not found")
    public User getUser(@PathParam("id") long id) {
        // ...
    }
}
```

- Swagger UI at `/q/swagger-ui`
- OpenAPI spec at `/q/openapi`
- Auto-generates schema from JAX-RS annotations and Java types

### MicroProfile Fault Tolerance
```java
@ApplicationScoped
public class ExternalServiceClient {

    @Retry(maxRetries = 3, delay = 500, delayUnit = ChronoUnit.MILLIS)
    @Timeout(value = 5, unit = ChronoUnit.SECONDS)
    @CircuitBreaker(requestVolumeThreshold = 10, failureRatio = 0.5,
                    delay = 10, delayUnit = ChronoUnit.SECONDS)
    @Fallback(fallbackMethod = "fallbackGetData")
    public String getData(String key) {
        return externalService.fetch(key);
    }

    public String fallbackGetData(String key) {
        return cachedData.get(key);  // Return cached version
    }
}
```

Built-in patterns: `@Retry`, `@Timeout`, `@CircuitBreaker`, `@Bulkhead`, `@Fallback`, `@Asynchronous`.

### MicroProfile REST Client
```java
@Path("/api")
@RegisterRestClient(configKey = "user-service")
public interface UserServiceClient {

    @GET
    @Path("/users/{id}")
    User getUser(@PathParam("id") long id);

    @POST
    @Path("/users")
    User createUser(CreateUserRequest request);
}

// Configuration
quarkus.rest-client.user-service.url=https://user-service:8080
quarkus.rest-client.user-service.scope=jakarta.inject.Singleton
```

## Dev Services

Quarkus automatically starts required services (databases, message brokers, etc.)
in Docker containers during development and testing.

```properties
# No configuration needed — Quarkus detects PostgreSQL dependency
# and starts a container automatically
%dev.quarkus.datasource.devservices.enabled=true  # This is the default!
```

### Supported Dev Services
| Service          | Dependency                          | Container Started              |
|------------------|-------------------------------------|-------------------------------|
| PostgreSQL       | `quarkus-jdbc-postgresql`           | PostgreSQL container           |
| MySQL            | `quarkus-jdbc-mysql`                | MySQL container                |
| MongoDB          | `quarkus-mongodb-client`            | MongoDB container              |
| Kafka            | `quarkus-smallrye-reactive-messaging-kafka` | Kafka + Zookeeper     |
| Redis            | `quarkus-redis-client`              | Redis container                |
| Elasticsearch    | `quarkus-elasticsearch-rest-client` | Elasticsearch container        |
| RabbitMQ         | `quarkus-smallrye-reactive-messaging-rabbitmq` | RabbitMQ container |
| Keycloak         | `quarkus-oidc`                      | Keycloak container             |
| Infinispan       | `quarkus-infinispan-client`         | Infinispan container           |

**No Docker Compose files needed for development.** Just add the dependency, and Quarkus
starts the required container. This is a significant developer experience advantage.

## Continuous Testing

Quarkus runs tests automatically when code changes:

```bash
# Start dev mode with continuous testing
./mvnw quarkus:dev
# Press 'r' to run tests
# Press 'o' to toggle continuous testing on/off
# Tests re-run automatically on code changes
```

Tests affected by a code change are automatically detected and re-run.
Failed tests are re-run first for fast feedback.

## Live Coding (Dev Mode)

```bash
./mvnw quarkus:dev
# Application starts and reloads on every code change
# No restart needed — changes are reflected in ~1 second
# Background compilation: save file -> request served with new code
```

Features in dev mode:
- **Hot reload** — code changes applied without restart
- **Dev UI** at `/q/dev-ui` — browse extensions, configuration, beans, endpoints
- **Continuous testing** — tests run on code change
- **Dev Services** — containers auto-started
- **Database migration** — Flyway/Liquibase applied automatically

## Persistence

### Hibernate ORM with Panache (Active Record Pattern)
```java
@Entity
public class User extends PanacheEntity {
    public String name;
    public String email;
    public LocalDateTime createdAt;

    // Active Record style — no repository needed
    public static User findByEmail(String email) {
        return find("email", email).firstResult();
    }

    public static List<User> findActive() {
        return find("active", true).list();
    }
}

// Usage
User user = new User();
user.name = "John";
user.email = "john@example.com";
user.persist();  // Save to database

User found = User.findByEmail("john@example.com");
long count = User.count();
User.deleteById(42L);
```

### Repository Pattern (Alternative)
```java
@ApplicationScoped
public class UserRepository implements PanacheRepository<User> {
    public User findByEmail(String email) {
        return find("email", email).firstResult();
    }
}
```

### Reactive Persistence (Hibernate Reactive + Panache)
```java
@Entity
public class User extends PanacheEntityBase {
    @Id @GeneratedValue
    public Long id;
    public String name;

    public static Uni<User> findByEmail(String email) {
        return find("email", email).firstResult();
    }
}
```

## Configuration

```properties
# application.properties
quarkus.http.port=8080
quarkus.datasource.db-kind=postgresql
quarkus.datasource.username=${DB_USER:postgres}
quarkus.datasource.password=${DB_PASSWORD:postgres}
quarkus.datasource.jdbc.url=jdbc:postgresql://localhost:5432/mydb

# Profile-specific configuration
%dev.quarkus.datasource.jdbc.url=jdbc:postgresql://localhost:5432/devdb
%test.quarkus.datasource.jdbc.url=jdbc:postgresql://localhost:5432/testdb
%prod.quarkus.log.level=INFO

# Native image specific
quarkus.native.additional-build-args=--initialize-at-run-time=org.example.MyClass
```

### Configuration Sources (priority order)
1. System properties
2. Environment variables
3. `.env` file
4. `application.properties` (in config dir)
5. `application.properties` (in classpath)
6. MicroProfile Config sources

## Structured Logging

```properties
# JSON logging for production
quarkus.log.console.json=true
quarkus.log.console.json.additional-field."service".value=user-service
quarkus.log.console.json.additional-field."environment".value=${ENV:dev}

# Log levels
quarkus.log.level=INFO
quarkus.log.category."com.example".level=DEBUG
quarkus.log.category."org.hibernate.SQL".level=DEBUG
```

```java
import io.quarkus.logging.Log;

@ApplicationScoped
public class UserService {

    public User create(CreateUserRequest request) {
        Log.infof("Creating user: email=%s", request.email());
        // Or with structured MDC
        MDC.put("userId", user.id.toString());
        Log.info("User created successfully");
        MDC.clear();
        return user;
    }
}
```

## Testing

### Unit Tests
```java
@QuarkusTest
class UserResourceTest {

    @Test
    void shouldCreateUser() {
        given()
            .contentType(ContentType.JSON)
            .body(new CreateUserRequest("test@example.com", "Test"))
        .when()
            .post("/users")
        .then()
            .statusCode(201)
            .body("email", equalTo("test@example.com"));
    }

    @Test
    void shouldReturn404ForUnknownUser() {
        given()
            .when().get("/users/999")
            .then().statusCode(404);
    }
}
```

### Native Image Tests
```java
@QuarkusIntegrationTest  // Runs against the native binary
class UserResourceIT extends UserResourceTest {
    // Inherits all tests, runs them against the native image
}
```

### Mocking
```java
@QuarkusTest
class OrderServiceTest {

    @InjectMock
    PaymentClient paymentClient;  // Mock injected into CDI

    @Test
    void shouldProcessOrder() {
        when(paymentClient.charge(any(), any()))
            .thenReturn(new PaymentResult(true));

        // Test order creation
        // ...
    }
}
```

## Extensions Ecosystem

Quarkus uses an extension model (similar to Spring Boot starters):

```bash
# List available extensions
./mvnw quarkus:list-extensions

# Add an extension
./mvnw quarkus:add-extension -Dextensions="resteasy-reactive-jackson,hibernate-orm-panache"
```

### Key Extensions
| Category          | Extension                                      |
|-------------------|-------------------------------------------------|
| REST              | `resteasy-reactive`, `resteasy-reactive-jackson`|
| Persistence       | `hibernate-orm-panache`, `hibernate-reactive`   |
| Security          | `oidc`, `security-jpa`, `keycloak-authorization`|
| Messaging         | `smallrye-reactive-messaging-kafka`             |
| Health            | `smallrye-health`                               |
| Metrics           | `micrometer-registry-prometheus`                |
| OpenAPI           | `smallrye-openapi`                              |
| Fault tolerance   | `smallrye-fault-tolerance`                      |
| REST client       | `rest-client-reactive`                          |
| Scheduler         | `scheduler`, `quartz`                           |
| Caching           | `cache`                                         |

## Comparison with Spring Boot

### Startup and Memory Comparison (Typical REST + JPA App)

| Metric                     | Spring Boot (JVM) | Spring Boot (Native) | Quarkus (JVM)  | Quarkus (Native) |
|----------------------------|-------------------|---------------------|----------------|------------------|
| Startup time               | 3-5 seconds       | 100-200ms           | 0.5-1.5 seconds| 10-50ms          |
| Memory (RSS)               | 300-500MB         | 80-150MB            | 100-200MB      | 20-50MB          |
| First response             | 3-6 seconds       | 150-300ms           | 0.5-2 seconds  | 15-60ms          |
| Container image size       | ~300MB (JRE)      | ~100MB              | ~300MB (JRE)   | ~50-80MB         |
| Container (distroless)     | ~200MB            | ~80MB               | ~200MB         | ~20-30MB         |
| Build time                 | 30-60 seconds     | 3-8 minutes         | 20-40 seconds  | 2-6 minutes      |

### Developer Experience
| Aspect                      | Spring Boot                        | Quarkus                          |
|-----------------------------|------------------------------------|----------------------------------|
| Hot reload                  | Spring DevTools (restart-based)    | True hot reload (no restart)     |
| Test infrastructure         | Testcontainers (manual setup)      | Dev Services (automatic)         |
| Continuous testing          | Separate test run                  | Built into dev mode              |
| Dev UI                      | None (third-party dashboards)      | Built-in `/q/dev-ui`            |
| Code generation             | Spring Initializr (web)            | `quarkus create app` (CLI)       |
| IDE support                 | Excellent (all major IDEs)         | Good (IntelliJ, VS Code)        |

### When Spring Boot Wins
- Larger ecosystem of starters and integrations
- More learning resources, tutorials, and Stack Overflow answers
- Larger talent pool (more developers know Spring)
- Better IDE tooling (Spring Tools Suite, IntelliJ Spring support)
- Brownfield projects already using Spring
- Virtual threads (Java 21+) reduce the need for reactive programming

### When Quarkus Wins
- Container-first / Kubernetes-native deployments
- Native compilation is a hard requirement (startup, memory, container size)
- Serverless / FaaS (cold start matters)
- Developer experience (Dev Services, live coding, continuous testing)
- MicroProfile standards compliance
- Resource-constrained environments (IoT, edge)
- New greenfield microservices projects

## Special Features

- **Build-time optimization** — framework overhead is paid at build, not at startup
- **Dev Services** — zero-config development infrastructure
- **Unified imperative + reactive** — mix styles in the same app
- **Extension ecosystem** — 500+ extensions, each optimized for build-time processing
- **Quarkus CLI** — `quarkus create app`, `quarkus ext add`, `quarkus build`
- **Compatible with Spring APIs** — `quarkus-spring-web`, `quarkus-spring-di` extensions

## Strengths

1. Fastest startup of any Java framework (10-50ms native)
2. Lowest memory footprint (20-50MB native)
3. Dev Services eliminate Docker Compose for development
4. Build-time DI catches injection errors at compile time
5. First-class GraalVM native image support
6. Live coding with true hot reload (not restart)
7. Continuous testing built into dev mode
8. MicroProfile standards compliance
9. Can mix imperative and reactive code
10. Excellent Kubernetes integration (health, config, secrets)

## Weaknesses

1. Smaller ecosystem than Spring Boot
2. Fewer learning resources and community answers
3. Smaller talent pool (fewer developers know Quarkus)
4. Some Spring libraries have no Quarkus equivalent
5. Build-time approach means some dynamic features require workarounds
6. Native compilation has longer build times
7. Not all Java libraries are native-compatible
8. ArC CDI is not 100% CDI spec compliant (intentional subset)
9. Less IDE tooling compared to Spring
10. Migration from Spring requires some effort

## When to Choose Quarkus

**Choose Quarkus when:**
- Building new cloud-native microservices
- Container size and startup time are critical (serverless, scale-to-zero)
- You want the best developer experience in Java (Dev Services, live coding)
- Native compilation is a requirement
- MicroProfile compliance is needed
- Resource efficiency matters (lower cloud costs)

**Avoid Quarkus when:**
- Team is deeply invested in Spring ecosystem
- You need a Spring-specific library with no Quarkus equivalent
- Hiring primarily from the Spring talent pool
- The project is a monolith where startup time doesn't matter
- You need maximum peak throughput (JVM mode with JIT may be better)
- Brownfield project with heavy Spring dependencies
