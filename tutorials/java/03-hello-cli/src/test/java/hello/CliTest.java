package hello;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

class CliTest {

    @Test
    void defaultOptions() {
        var opts = Options.parse(new String[]{});
        assertEquals("World", opts.name());
        assertFalse(opts.shout());
    }

    @Test
    void parseName() {
        var opts = Options.parse(new String[]{"--name", "Alice"});
        assertEquals("Alice", opts.name());
    }

    @Test
    void parseShout() {
        var opts = Options.parse(new String[]{"--shout"});
        assertTrue(opts.shout());
    }

    @Test
    void greetDefault() {
        assertEquals("Hello, World!", Cli.run(new Options("World", false)));
    }

    @Test
    void greetWithShout() {
        assertEquals("HELLO, ALICE!", Cli.run(new Options("Alice", true)));
    }

    @Test
    void parseCombined() {
        var opts = Options.parse(new String[]{"--name", "Bob", "--shout"});
        assertEquals("Bob", opts.name());
        assertTrue(opts.shout());
    }
}
