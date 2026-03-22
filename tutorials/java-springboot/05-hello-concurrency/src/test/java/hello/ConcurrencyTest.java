package hello;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
class ConcurrencyTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private AsyncGreeter greeter;

    @Test
    void homeEndpoint() throws Exception {
        mockMvc.perform(get("/"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.message").value("Hello, World!"));
    }

    @Test
    void parallelEndpoint() throws Exception {
        mockMvc.perform(get("/parallel"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.count").value(3))
                .andExpect(jsonPath("$.greetings[0]").value("Hello, Alice!"));
    }

    @Test
    void asyncGreeterReturnsCompletableFuture() throws Exception {
        String result = greeter.greet("Test").get();
        org.junit.jupiter.api.Assertions.assertEquals("Hello, Test!", result);
    }
}
