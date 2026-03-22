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

class WebServerTest {

    private HttpServer server;
    private int port;

    @BeforeEach
    void setUp() throws IOException {
        port = 0; // OS picks a free port
        server = Main.createServer(port);
        server.start();
        port = server.getAddress().getPort();
    }

    @AfterEach
    void tearDown() {
        server.stop(0);
    }

    @Test
    void rootReturnsHello() throws Exception {
        try (var client = HttpClient.newHttpClient()) {
            var req = HttpRequest.newBuilder(URI.create("http://localhost:" + port + "/")).build();
            var resp = client.send(req, HttpResponse.BodyHandlers.ofString());
            assertEquals(200, resp.statusCode());
            assertEquals("Hello, World!", resp.body());
        }
    }

    @Test
    void greetReturnsName() throws Exception {
        try (var client = HttpClient.newHttpClient()) {
            var req = HttpRequest.newBuilder(URI.create("http://localhost:" + port + "/greet/Alice")).build();
            var resp = client.send(req, HttpResponse.BodyHandlers.ofString());
            assertEquals(200, resp.statusCode());
            assertEquals("Hello, Alice!", resp.body());
        }
    }

    @Test
    void greetHandlerUnit() {
        assertEquals("Hello, Bob!", GreetHandler.greet("Bob"));
    }
}
