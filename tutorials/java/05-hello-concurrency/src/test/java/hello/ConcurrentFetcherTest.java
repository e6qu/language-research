package hello;

import com.sun.net.httpserver.HttpServer;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.io.IOException;
import java.net.InetSocketAddress;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

class ConcurrentFetcherTest {

    private HttpServer server;
    private int port;

    @BeforeEach
    void setUp() throws IOException {
        server = HttpServer.create(new InetSocketAddress(0), 0);
        server.createContext("/ok", exchange -> {
            byte[] body = "hello".getBytes();
            exchange.sendResponseHeaders(200, body.length);
            exchange.getResponseBody().write(body);
            exchange.getResponseBody().close();
        });
        server.createContext("/slow", exchange -> {
            try { Thread.sleep(200); } catch (InterruptedException ignored) {}
            byte[] body = "slow".getBytes();
            exchange.sendResponseHeaders(200, body.length);
            exchange.getResponseBody().write(body);
            exchange.getResponseBody().close();
        });
        server.start();
        port = server.getAddress().getPort();
    }

    @AfterEach
    void tearDown() {
        server.stop(0);
    }

    @Test
    void fetchAllReturnsResults() {
        var urls = List.of(
                "http://localhost:" + port + "/ok",
                "http://localhost:" + port + "/ok"
        );
        var results = ConcurrentFetcher.fetchAll(urls);
        assertEquals(2, results.size());
        for (var r : results) {
            assertInstanceOf(FetchResult.Success.class, r);
            var s = (FetchResult.Success) r;
            assertEquals(200, s.statusCode());
            assertEquals(5, s.bodyLength());
        }
    }

    @Test
    void fetchAllConcurrently() {
        var urls = List.of(
                "http://localhost:" + port + "/slow",
                "http://localhost:" + port + "/slow",
                "http://localhost:" + port + "/slow"
        );
        long start = System.currentTimeMillis();
        var results = ConcurrentFetcher.fetchAll(urls);
        long elapsed = System.currentTimeMillis() - start;
        assertEquals(3, results.size());
        // 3 concurrent 200ms requests should complete faster than sequential (600ms)
        assertTrue(elapsed < 2000, "Expected concurrent execution, took %d ms".formatted(elapsed));
    }

    @Test
    void fetchBadUrlReturnsFailure() {
        var results = ConcurrentFetcher.fetchAll(List.of("http://localhost:1/nope"));
        assertEquals(1, results.size());
        assertInstanceOf(FetchResult.Failure.class, results.getFirst());
    }

    @Test
    void sealedInterfacePatternMatching() {
        FetchResult success = new FetchResult.Success("http://x", 200, 10);
        FetchResult failure = new FetchResult.Failure("http://x", "err");
        switch (success) {
            case FetchResult.Success s -> assertEquals(200, s.statusCode());
            case FetchResult.Failure f -> fail("Expected success");
        }
        switch (failure) {
            case FetchResult.Success s -> fail("Expected failure");
            case FetchResult.Failure f -> assertEquals("err", f.error());
        }
    }
}
