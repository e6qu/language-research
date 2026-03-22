package hello;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.system.CapturedOutput;
import org.springframework.boot.test.system.OutputCaptureExtension;
import org.springframework.test.web.servlet.MockMvc;

import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
@ExtendWith(OutputCaptureExtension.class)
class LogControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    void helloLogsMessage(CapturedOutput output) throws Exception {
        mockMvc.perform(get("/"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.message").value("Hello, World!"));
        assertTrue(output.toString().contains("Handling root request"));
    }

    @Test
    void greetLogsName(CapturedOutput output) throws Exception {
        mockMvc.perform(get("/greet?name=Alice"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.message").value("Hello, Alice!"));
        assertTrue(output.toString().contains("Greeting user: Alice"));
    }

    @Test
    void warnEndpointLogsWarning(CapturedOutput output) throws Exception {
        mockMvc.perform(get("/warn"))
                .andExpect(status().isOk());
        assertTrue(output.toString().contains("warning example"));
    }
}
