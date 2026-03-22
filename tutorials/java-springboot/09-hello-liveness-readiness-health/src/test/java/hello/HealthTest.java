package hello;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest(classes = hello.App.class)
@AutoConfigureMockMvc
class HealthTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private DependencyHealthIndicator dependencyHealth;

    @Test
    void helloEndpoint() throws Exception {
        mockMvc.perform(get("/"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.message").value("Hello, World!"));
    }

    @Test
    void healthEndpointUp() throws Exception {
        dependencyHealth.setDependencyUp(true);
        mockMvc.perform(get("/actuator/health"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("UP"));
    }

    @Test
    void healthEndpointDown() throws Exception {
        dependencyHealth.setDependencyUp(false);
        mockMvc.perform(get("/actuator/health"))
                .andExpect(status().isServiceUnavailable())
                .andExpect(jsonPath("$.status").value("DOWN"));
        // Restore
        dependencyHealth.setDependencyUp(true);
    }

    @Test
    void livenessProbe() throws Exception {
        mockMvc.perform(get("/actuator/health/liveness"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("UP"));
    }

    @Test
    void readinessProbe() throws Exception {
        dependencyHealth.setDependencyUp(true);
        mockMvc.perform(get("/actuator/health/readiness"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("UP"));
    }
}
