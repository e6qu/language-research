package hello;

import io.quarkus.test.junit.QuarkusTest;
import org.junit.jupiter.api.Test;

import static io.restassured.RestAssured.given;
import static org.hamcrest.CoreMatchers.is;
import static org.hamcrest.CoreMatchers.containsString;

@QuarkusTest
class MetricsResourceTest {

    @Test
    void testHelloEndpoint() {
        given()
            .when().get("/")
            .then()
                .statusCode(200)
                .body("message", is("Hello, Metrics!"));
    }

    @Test
    void testPrometheusMetricsEndpoint() {
        // Hit the endpoint to generate metrics
        given().when().get("/").then().statusCode(200);

        // Check Prometheus metrics endpoint
        given()
            .when().get("/q/metrics")
            .then()
                .statusCode(200)
                .body(containsString("greetings_total"));
    }
}
