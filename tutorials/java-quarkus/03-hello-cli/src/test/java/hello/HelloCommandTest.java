package hello;

import io.quarkus.test.junit.QuarkusTest;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

@QuarkusTest
class HelloCommandTest {

    @Test
    void testDefaultGreeting() {
        assertEquals("Hello, World!", HelloCommand.formatGreeting("World", false));
    }

    @Test
    void testNamedGreeting() {
        assertEquals("Hello, Quarkus!", HelloCommand.formatGreeting("Quarkus", false));
    }

    @Test
    void testShoutGreeting() {
        assertEquals("HELLO, QUARKUS!", HelloCommand.formatGreeting("Quarkus", true));
    }
}
