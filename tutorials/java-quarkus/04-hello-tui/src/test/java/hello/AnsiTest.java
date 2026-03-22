package hello;

import io.quarkus.test.junit.QuarkusTest;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

@QuarkusTest
class AnsiTest {

    @Test
    void testColorize() {
        String result = Ansi.colorize("hello", Ansi.RED);
        assertTrue(result.startsWith("\033[31m"));
        assertTrue(result.endsWith("\033[0m"));
        assertTrue(result.contains("hello"));
    }

    @Test
    void testBold() {
        String result = Ansi.bold("test");
        assertTrue(result.startsWith("\033[1m"));
        assertTrue(result.contains("test"));
    }

    @Test
    void testBox() {
        String box = Ansi.box("Title", "Body text");
        assertTrue(box.contains("Title"));
        assertTrue(box.contains("Body text"));
        assertTrue(box.contains("+"));
        assertTrue(box.contains("|"));
    }

    @Test
    void testBoxStructure() {
        String box = Ansi.box("Hi", "World");
        String[] lines = box.split("\n");
        assertEquals(5, lines.length);
        assertTrue(lines[0].startsWith("+"));
        assertTrue(lines[0].endsWith("+"));
        assertTrue(lines[4].startsWith("+"));
        assertTrue(lines[4].endsWith("+"));
    }
}
