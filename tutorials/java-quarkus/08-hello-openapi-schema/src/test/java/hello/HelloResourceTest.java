package hello;

import io.quarkus.test.junit.QuarkusTest;
import org.junit.jupiter.api.Test;

import static io.restassured.RestAssured.given;
import static org.hamcrest.CoreMatchers.is;
import static org.hamcrest.CoreMatchers.notNullValue;
import static org.hamcrest.CoreMatchers.containsString;

@QuarkusTest
class HelloResourceTest {

    @Test
    void testRootEndpoint() {
        given()
            .when().get("/")
            .then()
                .statusCode(200)
                .body("message", is("Hello, World!"))
                .body("timestamp", notNullValue());
    }

    @Test
    void testGreetEndpoint() {
        given()
            .when().get("/greet/Quarkus")
            .then()
                .statusCode(200)
                .body("message", is("Hello, Quarkus!"));
    }

    @Test
    void testOpenApiEndpoint() {
        given()
            .when().get("/q/openapi")
            .then()
                .statusCode(200)
                .body(containsString("openapi"));
    }

    @Test
    void testSwaggerUi() {
        given()
            .when().get("/q/swagger-ui")
            .then()
                .statusCode(200);
    }
}
