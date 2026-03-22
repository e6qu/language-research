# Spring Boot — Java's Dominant Web Framework

## Overview

Spring Boot is an opinionated framework built on top of the Spring Framework that
simplifies the creation of production-ready Java applications. It provides auto-configuration,
embedded servers, and a "convention over configuration" approach that dramatically
reduces boilerplate.

- **Current stable**: Spring Boot 3.3+ (2025), requiring Java 17+ (21 recommended)
- **Spring Framework**: 6.x (underlying framework)
- **Created by**: Pivotal (now VMware Tanzu / Broadcom)
- **First release**: 2014
- **Market position**: Dominant Java web framework (~60-70% of Java web projects)

### Key Principle
Spring Boot makes it easy to create stand-alone, production-grade Spring applications
that you can "just run." No WAR files, no external application servers, no XML configuration.

## Auto-Configuration

Spring Boot's auto-configuration automatically configures your application based on
the dependencies on the classpath.

```java
@SpringBootApplication  // Combines @Configuration, @EnableAutoConfiguration, @ComponentScan
public class MyApplication {
    public static void main(String[] args) {
        SpringApplication.run(MyApplication.class, args);
    }
}
```

How it works:
1. You add `spring-boot-starter-data-jpa` to dependencies
2. Spring Boot detects JPA on the classpath
3. It auto-configures a DataSource, EntityManagerFactory, and TransactionManager
4. You write zero configuration code

### Configuration Properties
```yaml
# application.yml — externalized configuration
server:
  port: 8080
  shutdown: graceful

spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/mydb
    username: ${DB_USER}
    password: ${DB_PASSWORD}
  jpa:
    hibernate:
      ddl-auto: validate
    open-in-view: false

  jackson:
    default-property-inclusion: non_null
    serialization:
      write-dates-as-timestamps: false

logging:
  level:
    com.example: DEBUG
    org.springframework.web: INFO
```

Configuration profiles:
```yaml
# application-dev.yml  — active with spring.profiles.active=dev
# application-prod.yml — active with spring.profiles.active=prod
```

## Starters

Starters are curated dependency descriptors — one dependency pulls in everything needed:

| Starter                              | What It Provides                              |
|--------------------------------------|-----------------------------------------------|
| `spring-boot-starter-web`            | Embedded Tomcat, Spring MVC, JSON support     |
| `spring-boot-starter-webflux`        | Reactive web (Netty), WebFlux                 |
| `spring-boot-starter-data-jpa`       | JPA + Hibernate + connection pooling          |
| `spring-boot-starter-data-redis`     | Redis client (Lettuce)                        |
| `spring-boot-starter-security`       | Spring Security                               |
| `spring-boot-starter-actuator`       | Production monitoring endpoints               |
| `spring-boot-starter-test`           | JUnit 5, Mockito, AssertJ, Testcontainers     |
| `spring-boot-starter-validation`     | Bean Validation (Hibernate Validator)         |
| `spring-boot-starter-cache`          | Caching abstraction                           |
| `spring-boot-starter-amqp`           | RabbitMQ                                      |
| `spring-boot-starter-kafka`          | Apache Kafka                                  |

## Spring Web (MVC)

### REST Controllers
```java
@RestController
@RequestMapping("/api/v1/users")
public class UserController {

    private final UserService userService;

    public UserController(UserService userService) {  // Constructor injection
        this.userService = userService;
    }

    @GetMapping
    public List<UserDto> listUsers(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        return userService.findAll(PageRequest.of(page, size));
    }

    @GetMapping("/{id}")
    public ResponseEntity<UserDto> getUser(@PathVariable long id) {
        return userService.findById(id)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public UserDto createUser(@Valid @RequestBody CreateUserRequest request) {
        return userService.create(request);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteUser(@PathVariable long id) {
        userService.delete(id);
    }
}
```

### Exception Handling
```java
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(EntityNotFoundException.class)
    @ResponseStatus(HttpStatus.NOT_FOUND)
    public ProblemDetail handleNotFound(EntityNotFoundException ex) {
        ProblemDetail detail = ProblemDetail.forStatus(HttpStatus.NOT_FOUND);
        detail.setTitle("Not Found");
        detail.setDetail(ex.getMessage());
        return detail;
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public ProblemDetail handleValidation(MethodArgumentNotValidException ex) {
        ProblemDetail detail = ProblemDetail.forStatus(HttpStatus.BAD_REQUEST);
        detail.setTitle("Validation Failed");
        Map<String, String> errors = ex.getBindingResult().getFieldErrors().stream()
            .collect(Collectors.toMap(FieldError::getField, FieldError::getDefaultMessage));
        detail.setProperty("errors", errors);
        return detail;
    }
}
```

## Spring WebFlux (Reactive)

Non-blocking, reactive web framework built on Project Reactor:

```java
@RestController
@RequestMapping("/api/v1/users")
public class UserController {

    private final UserRepository repository;

    @GetMapping("/{id}")
    public Mono<UserDto> getUser(@PathVariable long id) {
        return repository.findById(id)
            .map(UserDto::from)
            .switchIfEmpty(Mono.error(new EntityNotFoundException("User not found")));
    }

    @GetMapping(produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    public Flux<UserDto> streamUsers() {
        return repository.findAll()
            .map(UserDto::from)
            .delayElements(Duration.ofMillis(100));
    }
}
```

### MVC vs WebFlux
| Aspect              | Spring MVC                       | Spring WebFlux                    |
|---------------------|----------------------------------|-----------------------------------|
| Threading model     | Thread-per-request               | Event loop (Netty)                |
| Blocking I/O        | Yes (traditional)                | Non-blocking                      |
| Server              | Tomcat (default)                 | Netty (default)                   |
| API style           | Imperative                       | Reactive (Mono/Flux)              |
| Virtual threads     | Excellent fit (Java 21+)         | Less benefit (already non-blocking)|
| Learning curve      | Lower                            | Higher (reactive is harder)       |
| Recommendation      | Default choice (with VT in 21+)  | When you need streaming/SSE       |

With Java 21 virtual threads, Spring MVC handles high concurrency without the complexity
of reactive programming. WebFlux is now primarily for streaming use cases.

## Spring Data

### JPA Repositories
```java
public interface UserRepository extends JpaRepository<User, Long> {

    Optional<User> findByEmail(String email);

    List<User> findByAgeGreaterThanOrderByNameAsc(int age);

    @Query("SELECT u FROM User u WHERE u.department = :dept AND u.active = true")
    List<User> findActiveDepartmentMembers(@Param("dept") String department);

    @Modifying
    @Query("UPDATE User u SET u.active = false WHERE u.lastLogin < :cutoff")
    int deactivateInactiveUsers(@Param("cutoff") LocalDateTime cutoff);
}
```

Spring Data generates the implementation at runtime from method names and annotations.

### Other Spring Data Modules
- **Spring Data Redis** — Redis operations with Repository abstraction
- **Spring Data MongoDB** — MongoDB document repositories
- **Spring Data Elasticsearch** — Elasticsearch integration
- **Spring Data R2DBC** — reactive relational database access
- **Spring Data JDBC** — simpler alternative to JPA (no lazy loading, no caching)

## Spring Security

```java
@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        return http
            .csrf(csrf -> csrf.disable())  // Disable for APIs
            .sessionManagement(session ->
                session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/api/public/**").permitAll()
                .requestMatchers("/api/admin/**").hasRole("ADMIN")
                .requestMatchers("/actuator/health").permitAll()
                .anyRequest().authenticated()
            )
            .oauth2ResourceServer(oauth2 -> oauth2.jwt(Customizer.withDefaults()))
            .build();
    }
}
```

Supports: JWT, OAuth2, OIDC, LDAP, SAML, form login, basic auth, API keys, custom authentication.

## Actuator (Production Monitoring)

Spring Boot Actuator provides production-ready features out of the box:

```yaml
management:
  endpoints:
    web:
      exposure:
        include: health, info, metrics, prometheus, env, loggers
  endpoint:
    health:
      show-details: when_authorized
      probes:
        enabled: true  # Kubernetes liveness/readiness probes
  metrics:
    tags:
      application: ${spring.application.name}
```

### Built-in Endpoints
| Endpoint           | Purpose                                              |
|--------------------|------------------------------------------------------|
| `/actuator/health` | Application health (liveness + readiness)            |
| `/actuator/info`   | Application info (build, git, custom)                |
| `/actuator/metrics`| Micrometer metrics                                   |
| `/actuator/prometheus` | Prometheus-format metrics export                |
| `/actuator/env`    | Environment properties (sanitized)                   |
| `/actuator/loggers`| View and change log levels at runtime                |
| `/actuator/beans`  | All Spring beans in the context                      |
| `/actuator/mappings`| All @RequestMapping paths                           |
| `/actuator/threaddump` | Thread dump                                     |
| `/actuator/heapdump`  | Heap dump (binary)                               |

### Custom Health Indicators
```java
@Component
public class DatabaseHealthIndicator implements HealthIndicator {

    private final DataSource dataSource;

    @Override
    public Health health() {
        try (var conn = dataSource.getConnection()) {
            if (conn.isValid(2)) {
                return Health.up()
                    .withDetail("database", "PostgreSQL")
                    .withDetail("connectionPool", "active")
                    .build();
            }
        } catch (SQLException e) {
            return Health.down(e).build();
        }
        return Health.down().build();
    }
}
```

### Kubernetes Probes
```yaml
# Kubernetes deployment
livenessProbe:
  httpGet:
    path: /actuator/health/liveness
    port: 8080
  initialDelaySeconds: 10
readinessProbe:
  httpGet:
    path: /actuator/health/readiness
    port: 8080
  initialDelaySeconds: 5
```

## OpenAPI (springdoc-openapi)

```java
// Dependency: org.springdoc:springdoc-openapi-starter-webmvc-ui

@OpenAPIDefinition(
    info = @Info(title = "User API", version = "1.0",
        description = "User management REST API")
)
@Configuration
public class OpenApiConfig {}

// On controllers:
@Operation(summary = "Create a new user")
@ApiResponses({
    @ApiResponse(responseCode = "201", description = "User created",
        content = @Content(schema = @Schema(implementation = UserDto.class))),
    @ApiResponse(responseCode = "400", description = "Invalid input"),
    @ApiResponse(responseCode = "409", description = "Email already exists")
})
@PostMapping
public ResponseEntity<UserDto> createUser(@Valid @RequestBody CreateUserRequest request) {
    // ...
}
```

- Swagger UI available at `/swagger-ui.html`
- OpenAPI JSON/YAML at `/v3/api-docs`
- Automatic schema generation from Java types (records work great)

## Micrometer (Metrics)

Micrometer is the metrics facade for Spring Boot (like SLF4J is for logging):

```java
@Component
public class OrderService {

    private final Counter orderCounter;
    private final Timer orderTimer;
    private final DistributionSummary orderValue;

    public OrderService(MeterRegistry registry) {
        this.orderCounter = registry.counter("orders.created");
        this.orderTimer = registry.timer("orders.processing.time");
        this.orderValue = DistributionSummary.builder("orders.value")
            .baseUnit("dollars")
            .publishPercentiles(0.5, 0.95, 0.99)
            .register(registry);
    }

    public Order createOrder(CreateOrderRequest request) {
        return orderTimer.record(() -> {
            Order order = processOrder(request);
            orderCounter.increment();
            orderValue.record(order.total());
            return order;
        });
    }
}
```

Auto-instrumented metrics (out of the box):
- JVM metrics (memory, GC, threads, classloading)
- HTTP request metrics (count, duration, status codes)
- Database connection pool metrics (HikariCP)
- Cache metrics
- Kafka consumer/producer metrics
- Spring MVC request metrics

## Spring Native (GraalVM)

Compile Spring Boot applications to native binaries:

```xml
<plugin>
    <groupId>org.graalvm.buildtools</groupId>
    <artifactId>native-maven-plugin</artifactId>
</plugin>
```

```bash
mvn -Pnative native:compile
# Result: native binary, ~50-100MB
# Startup: ~100ms (vs ~2-5s JVM)
# Memory: ~50-100MB (vs ~200-500MB JVM)
```

### AOT Processing (Spring 6+)
Spring's AOT (Ahead-of-Time) engine processes the application context at build time:
- Generates optimized bean definitions
- Pre-computes configuration
- Generates GraalVM reflection/proxy hints
- Reduces startup time even without native compilation

### Tradeoffs
| Aspect            | JVM Mode                         | Native Mode                       |
|-------------------|----------------------------------|-----------------------------------|
| Startup time      | 2-10 seconds                     | 50-200 milliseconds               |
| Peak throughput   | Higher (JIT optimization)        | Lower (no runtime optimization)   |
| Memory usage      | Higher (200-500MB typical)       | Lower (50-100MB typical)          |
| Build time        | Fast (seconds)                   | Slow (2-10 minutes)               |
| Compatibility     | All libraries work               | Some libraries need configuration |
| Debugging         | Full support                     | Limited                           |
| Best for          | Long-running services            | Serverless, CLI, short-lived      |

## Testing

### Unit Tests
```java
@ExtendWith(MockitoExtension.class)
class UserServiceTest {

    @Mock UserRepository repository;
    @InjectMocks UserService service;

    @Test
    void shouldCreateUser() {
        var request = new CreateUserRequest("john@example.com", "John");
        when(repository.save(any())).thenAnswer(inv -> {
            User u = inv.getArgument(0);
            return u.withId(1L);
        });

        UserDto result = service.create(request);

        assertThat(result.email()).isEqualTo("john@example.com");
        verify(repository).save(any());
    }
}
```

### Integration Tests
```java
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@Testcontainers
class UserControllerIntegrationTest {

    @Container
    static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:16");

    @DynamicPropertySource
    static void configureProperties(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", postgres::getJdbcUrl);
        registry.add("spring.datasource.username", postgres::getUsername);
        registry.add("spring.datasource.password", postgres::getPassword);
    }

    @Autowired TestRestTemplate restTemplate;

    @Test
    void shouldCreateAndRetrieveUser() {
        var request = new CreateUserRequest("test@example.com", "Test");
        var response = restTemplate.postForEntity("/api/v1/users", request, UserDto.class);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        assertThat(response.getBody().email()).isEqualTo("test@example.com");
    }
}
```

### Slice Tests
```java
@WebMvcTest(UserController.class)     // Only web layer
@DataJpaTest                            // Only JPA layer
@JsonTest                               // Only JSON serialization
```

## Comparison with Quarkus

| Aspect                  | Spring Boot                      | Quarkus                           |
|-------------------------|----------------------------------|-----------------------------------|
| Market share            | Dominant (~65%)                  | Growing (~10-15%)                 |
| DI model                | Runtime reflection               | Build-time (ArC)                  |
| Native compilation      | Via Spring Native / GraalVM      | First-class GraalVM support       |
| Startup (JVM)           | 2-5 seconds                      | 0.5-2 seconds                     |
| Startup (native)        | 100-200ms                        | 10-50ms                           |
| Memory (JVM)            | 200-500MB                        | 100-200MB                         |
| Memory (native)         | 50-100MB                         | 20-50MB                           |
| Developer experience    | Mature, huge community           | Dev Services, live coding         |
| Library ecosystem       | Everything has a Spring starter   | MicroProfile + some Spring compat |
| Learning resources      | Enormous                         | Growing, good docs                |
| Enterprise adoption     | Banks, insurance, governments    | Cloud-native, Red Hat ecosystem   |
| Reactive                | WebFlux (Project Reactor)        | Vert.x/Mutiny                     |
| Testing                 | Excellent (Testcontainers, etc.) | Dev Services, continuous testing  |

### When to Choose Spring Boot
- Team already knows Spring
- You need the widest possible library/starter ecosystem
- Enterprise environment where Spring is the standard
- Virtual threads (Java 21+) solve your concurrency needs without reactive
- You want the most learning resources and community support

### When to Choose Quarkus Instead
- Container-first / Kubernetes-native development
- Native compilation is a hard requirement
- You want faster startup and lower memory
- Serverless / FaaS use case
- You prefer MicroProfile standards
- See [JAVA_QUARKUS.md](JAVA_QUARKUS.md) for full Quarkus coverage

## Strengths

1. Auto-configuration eliminates most boilerplate
2. Actuator provides production monitoring out of the box
3. Massive ecosystem — a starter exists for almost everything
4. Excellent documentation and community
5. Mature, battle-tested in production at massive scale
6. Spring Security is comprehensive (if complex)
7. Micrometer metrics integrate with all major monitoring systems
8. Virtual threads (Java 21+) simplify high-concurrency code
9. Strong IDE support (IntelliJ IDEA, Spring Tools Suite)
10. Backwards compatible — upgrades are well-documented

## Weaknesses

1. "Magic" — auto-configuration can be hard to debug when it goes wrong
2. Heavy memory footprint in JVM mode
3. Slow startup (JVM mode) — 2-10 seconds is normal
4. Annotation-heavy code can be hard to follow
5. Spring Security has a steep learning curve
6. Complex dependency trees — starter dependencies pull in a lot
7. Native compilation support is improving but still has rough edges
8. Framework lock-in — Spring-specific patterns don't transfer easily
9. XML/annotation configuration debates persist in teams
10. Over-engineering is easy — Spring provides many ways to do things

## When to Choose Spring Boot

**Choose Spring Boot when:**
- Building Java enterprise web applications or APIs
- Team has Spring experience (most Java developers do)
- You need comprehensive security, data access, messaging integration
- Production monitoring (Actuator) is important
- You're in an organization that standardizes on Spring

**Avoid Spring Boot when:**
- Building simple microservices where memory/startup matters (consider Quarkus)
- The project is small enough that a framework is overkill (use Javalin)
- You want to avoid framework "magic" and prefer explicit code
- Serverless / FaaS with cold starts (consider Quarkus native)
- Not using Java at all (many other languages have simpler web stacks)
