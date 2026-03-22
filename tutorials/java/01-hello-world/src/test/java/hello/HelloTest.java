package hello;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

class HelloTest {

    @Test
    void greetWithName() {
        assertEquals("Hello, Alice!", Hello.greet("Alice"));
    }

    @Test
    void greetWithWorld() {
        assertEquals("Hello, World!", Hello.greet("World"));
    }
}
