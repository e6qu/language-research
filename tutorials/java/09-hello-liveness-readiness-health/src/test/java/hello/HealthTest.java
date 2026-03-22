package hello;

import com.sun.net.httpserver.HttpServer;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;

import static org.junit.jupiter.api.Assertions.*;

class HealthTest {

    private HealthChecker checker;
    private HttpServer server;
    private int port;

    @BeforeEach
    void setUp() throws IOException {
        checker = new HealthChecker();
        checker.register("db");
        server = Main.createServer(0, checker);
        server.start();
        port = server.getAddress().getPort();
    }

    @AfterEach
    void tearDown() {
        server.stop(0);
    }

    // --- Unit tests for HealthChecker ---

    @Test
    void aliveByDefault() {
        assertTrue(checker.isAlive());
    }

    @Test
    void notReadyWhenDependencyDown() {
        assertFalse(checker.isReady());
    }

    @Test
    void readyWhenAllUp() {
        checker.update("db", HealthChecker.Status.UP, "ok");
        assertTrue(checker.isReady());
    }

    @Test
    void notReadyWhenNotAlive() {
        checker.update("db", HealthChecker.Status.UP, "ok");
        checker.setAlive(false);
        assertFalse(checker.isReady());
    }

    @Test
    void toJsonContainsFields() {
        checker.update("db", HealthChecker.Status.UP, "connected");
        String json = checker.toJson();
        assertTrue(json.contains("\"alive\":true"));
        assertTrue(json.contains("\"ready\":true"));
        assertTrue(json.contains("\"db\""));
        assertTrue(json.contains("\"status\":\"UP\""));
    }

    // --- Integration tests ---

    @Test
    void healthzReturns200WhenAlive() throws Exception {
        try (var client = HttpClient.newHttpClient()) {
            var resp = client.send(
                    HttpRequest.newBuilder(URI.create("http://localhost:" + port + "/healthz")).build(),
                    HttpResponse.BodyHandlers.ofString());
            assertEquals(200, resp.statusCode());
            assertEquals("OK", resp.body());
        }
    }

    @Test
    void healthzReturns503WhenDead() throws Exception {
        checker.setAlive(false);
        try (var client = HttpClient.newHttpClient()) {
            var resp = client.send(
                    HttpRequest.newBuilder(URI.create("http://localhost:" + port + "/healthz")).build(),
                    HttpResponse.BodyHandlers.ofString());
            assertEquals(503, resp.statusCode());
        }
    }

    @Test
    void readyzReturns503WhenNotReady() throws Exception {
        try (var client = HttpClient.newHttpClient()) {
            var resp = client.send(
                    HttpRequest.newBuilder(URI.create("http://localhost:" + port + "/readyz")).build(),
                    HttpResponse.BodyHandlers.ofString());
            assertEquals(503, resp.statusCode());
            assertEquals("NOT READY", resp.body());
        }
    }

    @Test
    void readyzReturns200WhenReady() throws Exception {
        checker.update("db", HealthChecker.Status.UP, "ok");
        try (var client = HttpClient.newHttpClient()) {
            var resp = client.send(
                    HttpRequest.newBuilder(URI.create("http://localhost:" + port + "/readyz")).build(),
                    HttpResponse.BodyHandlers.ofString());
            assertEquals(200, resp.statusCode());
            assertEquals("READY", resp.body());
        }
    }

    @Test
    void healthReturnsJson() throws Exception {
        checker.update("db", HealthChecker.Status.UP, "ok");
        try (var client = HttpClient.newHttpClient()) {
            var resp = client.send(
                    HttpRequest.newBuilder(URI.create("http://localhost:" + port + "/health")).build(),
                    HttpResponse.BodyHandlers.ofString());
            assertEquals(200, resp.statusCode());
            assertTrue(resp.headers().firstValue("Content-Type").orElse("").contains("application/json"));
            assertTrue(resp.body().contains("\"alive\":true"));
        }
    }
}
