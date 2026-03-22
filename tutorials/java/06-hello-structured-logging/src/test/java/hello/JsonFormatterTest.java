package hello;

import org.junit.jupiter.api.Test;

import java.util.logging.Level;
import java.util.logging.LogRecord;

import static org.junit.jupiter.api.Assertions.*;

class JsonFormatterTest {

    private final JsonFormatter formatter = new JsonFormatter();

    @Test
    void formatsAsJson() {
        var record = new LogRecord(Level.INFO, "test message");
        record.setLoggerName("hello.Test");
        String output = formatter.format(record);
        assertTrue(output.contains("\"level\":\"INFO\""));
        assertTrue(output.contains("\"message\":\"test message\""));
        assertTrue(output.contains("\"logger\":\"hello.Test\""));
        assertTrue(output.contains("\"timestamp\":\""));
    }

    @Test
    void endsWithNewline() {
        var record = new LogRecord(Level.INFO, "msg");
        record.setLoggerName("test");
        String output = formatter.format(record);
        assertTrue(output.endsWith("\n"));
    }

    @Test
    void escapesSpecialChars() {
        assertEquals("line1\\nline2", JsonFormatter.escapeJson("line1\nline2"));
        assertEquals("say \\\"hi\\\"", JsonFormatter.escapeJson("say \"hi\""));
        assertEquals("back\\\\slash", JsonFormatter.escapeJson("back\\slash"));
    }

    @Test
    void escapesNullSafely() {
        assertEquals("", JsonFormatter.escapeJson(null));
    }

    @Test
    void formatsWithParameters() {
        var record = new LogRecord(Level.SEVERE, "error: {0}");
        record.setLoggerName("test");
        record.setParameters(new Object[]{"disk full"});
        String output = formatter.format(record);
        assertTrue(output.contains("error: disk full"));
    }
}
