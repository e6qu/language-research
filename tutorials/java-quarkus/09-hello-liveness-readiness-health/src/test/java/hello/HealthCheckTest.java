package hello;

import io.quarkus.test.junit.QuarkusTest;
import org.junit.jupiter.api.Test;

import static io.restassured.RestAssured.given;
import static org.hamcrest.CoreMatchers.is;
import static org.hamcrest.CoreMatchers.containsString;

@QuarkusTest
class HealthCheckTest {

    @Test
    void testHelloEndpoint() {
        given()
            .when().get("/")
            .then()
                .statusCode(200)
                .body("message", is("Hello, Health Checks!"));
    }

    @Test
    void testHealthEndpoint() {
        given()
            .when().get("/q/health")
            .then()
                .statusCode(200)
                .body("status", is("UP"));
    }

    @Test
    void testLivenessEndpoint() {
        given()
            .when().get("/q/health/live")
            .then()
                .statusCode(200)
                .body("status", is("UP"))
                .body(containsString("alive"));
    }

    @Test
    void testReadinessEndpoint() {
        given()
            .when().get("/q/health/ready")
            .then()
                .statusCode(200)
                .body("status", is("UP"))
                .body(containsString("ready"));
    }

    @Test
    void testStartupEndpoint() {
        given()
            .when().get("/q/health/started")
            .then()
                .statusCode(200)
                .body("status", is("UP"))
                .body(containsString("started"));
    }
}
