package hello;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

class GreeterTest {

    private final Greeter greeter = new Greeter();

    @Test
    void greetsWithName() {
        assertEquals("Hello, Alice!", greeter.greet("Alice", false));
    }

    @Test
    void greetsDefault() {
        assertEquals("Hello, World!", greeter.greet("World", false));
    }

    @Test
    void shoutsWhenFlagSet() {
        assertEquals("HELLO, ALICE!", greeter.greet("Alice", true));
    }
}
