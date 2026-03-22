package hello;

import io.quarkus.test.junit.QuarkusTest;
import org.junit.jupiter.api.Test;

import static io.restassured.RestAssured.given;
import static org.hamcrest.CoreMatchers.is;

@QuarkusTest
class HelloResourceTest {

    @Test
    void testRootEndpoint() {
        given()
            .when().get("/")
            .then()
                .statusCode(200)
                .body("message", is("Hello, World!"));
    }

    @Test
    void testGreetEndpoint() {
        given()
            .when().get("/greet/Quarkus")
            .then()
                .statusCode(200)
                .body("message", is("Hello, Quarkus!"));
    }
}
