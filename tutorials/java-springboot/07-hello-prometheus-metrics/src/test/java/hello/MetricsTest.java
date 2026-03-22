package hello;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
class MetricsTest {

    @Autowired
    private org.springframework.boot.test.web.client.TestRestTemplate restTemplate;

    @Test
    void helloEndpoint() {
        String body = restTemplate.getForObject("/", String.class);
        assert body != null && body.contains("Hello");
    }

    @Test
    void prometheusEndpointAvailable() {
        // Hit the app first to generate metrics
        restTemplate.getForObject("/", String.class);

        var response = restTemplate.getForEntity("/actuator/prometheus", String.class);
        assert response.getStatusCode().is2xxSuccessful() : "prometheus endpoint returned " + response.getStatusCode();
    }

    @Test
    void actuatorHealthAvailable() {
        String health = restTemplate.getForObject("/actuator/health", String.class);
        assert health != null && health.contains("UP");
    }
}
