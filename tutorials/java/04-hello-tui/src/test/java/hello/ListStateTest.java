package hello;

import org.junit.jupiter.api.Test;
import java.util.List;
import static org.junit.jupiter.api.Assertions.*;

class ListStateTest {

    @Test
    void initialSelection() {
        var state = new ListState(List.of("A", "B", "C"));
        assertEquals(0, state.selected());
        assertEquals("A", state.selectedItem());
    }

    @Test
    void moveDown() {
        var state = new ListState(List.of("A", "B", "C"));
        state.moveDown();
        assertEquals(1, state.selected());
        assertEquals("B", state.selectedItem());
    }

    @Test
    void moveUp() {
        var state = new ListState(List.of("A", "B", "C"));
        state.moveDown();
        state.moveDown();
        state.moveUp();
        assertEquals(1, state.selected());
    }

    @Test
    void cannotMoveAboveFirst() {
        var state = new ListState(List.of("A", "B"));
        state.moveUp();
        assertEquals(0, state.selected());
    }

    @Test
    void cannotMoveBelowLast() {
        var state = new ListState(List.of("A", "B"));
        state.moveDown();
        state.moveDown();
        state.moveDown();
        assertEquals(1, state.selected());
    }

    @Test
    void renderContainsItems() {
        var state = new ListState(List.of("X", "Y"));
        String rendered = state.render();
        assertTrue(rendered.contains("X"));
        assertTrue(rendered.contains("Y"));
    }

    @Test
    void renderHighlightsSelected() {
        var state = new ListState(List.of("A", "B"));
        String rendered = state.render();
        // Selected item (A) uses reverse video escape
        assertTrue(rendered.contains("\033[7m"));
    }
}
