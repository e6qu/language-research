package hello;

import org.junit.jupiter.api.Test;
import java.util.List;
import java.util.Map;
import static org.junit.jupiter.api.Assertions.*;

class OpenApiTest {

    @Test
    void specContainsVersion() {
        var spec = OpenApiSpec.build();
        assertEquals("3.0.3", spec.get("openapi"));
    }

    @Test
    void specContainsInfo() {
        var spec = OpenApiSpec.build();
        @SuppressWarnings("unchecked")
        var info = (Map<String, Object>) spec.get("info");
        assertEquals("Hello API", info.get("title"));
        assertEquals("1.0.0", info.get("version"));
    }

    @Test
    void specContainsPaths() {
        var spec = OpenApiSpec.build();
        @SuppressWarnings("unchecked")
        var paths = (Map<String, Object>) spec.get("paths");
        assertTrue(paths.containsKey("/greet/{name}"));
    }

    @Test
    void toJsonProducesValidOutput() {
        String json = OpenApiSpec.toJson();
        assertTrue(json.contains("\"openapi\":\"3.0.3\""));
        assertTrue(json.contains("Hello API"));
    }

    @Test
    void jsonWriterString() {
        assertEquals("\"hello\"", JsonWriter.toJson("hello"));
    }

    @Test
    void jsonWriterNumber() {
        assertEquals("42", JsonWriter.toJson(42));
    }

    @Test
    void jsonWriterBoolean() {
        assertEquals("true", JsonWriter.toJson(true));
    }

    @Test
    void jsonWriterNull() {
        assertEquals("null", JsonWriter.toJson(null));
    }

    @Test
    void jsonWriterMap() {
        String json = JsonWriter.toJson(Map.of("key", "val"));
        assertEquals("{\"key\":\"val\"}", json);
    }

    @Test
    void jsonWriterList() {
        String json = JsonWriter.toJson(List.of(1, 2, 3));
        assertEquals("[1,2,3]", json);
    }

    @Test
    void jsonWriterEscapes() {
        String json = JsonWriter.toJson("say \"hi\"");
        assertEquals("\"say \\\"hi\\\"\"", json);
    }
}
