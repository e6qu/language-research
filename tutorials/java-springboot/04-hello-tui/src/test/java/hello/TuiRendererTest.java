package hello;

import org.junit.jupiter.api.Test;

import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

class TuiRendererTest {

    @Test
    void storesName() {
        TuiRenderer renderer = new TuiRenderer("Alice");
        assertEquals("Alice", renderer.getName());
    }

    @Test
    void renderPlainOutput() {
        TuiRenderer renderer = new TuiRenderer("World");
        assertEquals("Hello, World!", renderer.renderPlain());
    }

    @Test
    void renderProducesFourLines() {
        TuiRenderer renderer = new TuiRenderer("Bob");
        List<String> lines = renderer.render();
        assertEquals(4, lines.size());
    }

    @Test
    void renderContainsGreeting() {
        TuiRenderer renderer = new TuiRenderer("Carol");
        List<String> lines = renderer.render();
        assertTrue(lines.get(1).contains("Hello, Carol!"));
    }
}
