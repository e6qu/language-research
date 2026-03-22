package hello;

import io.quarkus.test.junit.QuarkusTest;
import org.junit.jupiter.api.Test;

import static io.restassured.RestAssured.given;
import static org.hamcrest.CoreMatchers.is;
import static org.hamcrest.CoreMatchers.notNullValue;
import static org.hamcrest.Matchers.hasSize;

@QuarkusTest
class ConcurrentResourceTest {

    @Test
    void testRootEndpoint() {
        given()
            .when().get("/")
            .then()
                .statusCode(200)
                .body("greeting", is("Hello, Concurrency!"))
                .body("timestamp", notNullValue())
                .body("thread", notNullValue());
    }

    @Test
    void testParallelEndpoint() {
        given()
            .when().get("/parallel")
            .then()
                .statusCode(200)
                .body("$", hasSize(3));
    }
}
