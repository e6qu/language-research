package hello;

import io.quarkus.test.junit.QuarkusTest;
import org.junit.jupiter.api.Test;

import static io.restassured.RestAssured.given;
import static org.hamcrest.CoreMatchers.is;

@QuarkusTest
class LoggingResourceTest {

    @Test
    void testRootEndpoint() {
        given()
            .when().get("/")
            .then()
                .statusCode(200)
                .body("message", is("Hello, Structured Logging!"));
    }

    @Test
    void testLogInfo() {
        given()
            .when().get("/log/info")
            .then()
                .statusCode(200)
                .body("logged", is("info"));
    }

    @Test
    void testLogWarn() {
        given()
            .when().get("/log/warn")
            .then()
                .statusCode(200)
                .body("logged", is("warn"));
    }

    @Test
    void testLogError() {
        given()
            .when().get("/log/error")
            .then()
                .statusCode(200)
                .body("logged", is("error"));
    }
}
