package hello;

import io.quarkus.test.common.http.TestHTTPResource;
import io.quarkus.test.junit.QuarkusTest;
import org.junit.jupiter.api.Test;

import java.net.URL;

import static io.restassured.RestAssured.given;
import static org.hamcrest.CoreMatchers.is;
import static org.junit.jupiter.api.Assertions.assertNotNull;

@QuarkusTest
class HelloResourceTest {

    @TestHTTPResource("/")
    URL url;

    @Test
    void testHelloEndpoint() {
        given()
            .when().get("/")
            .then()
                .statusCode(200)
                .body(is("Hello, World!"));
    }

    @Test
    void testHTTPResource() {
        assertNotNull(url);
    }
}
