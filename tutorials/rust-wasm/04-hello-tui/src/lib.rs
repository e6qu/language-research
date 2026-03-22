use wasm_bindgen::prelude::*;
use std::cell::RefCell;
use std::rc::Rc;

pub const COLS: usize = 40;
pub const ROWS: usize = 20;
pub const CELL_W: f64 = 14.0;
pub const CELL_H: f64 = 20.0;

pub struct Grid {
    pub cells: Vec<Vec<char>>,
    pub cursor_row: usize,
    pub cursor_col: usize,
}

impl Grid {
    pub fn new() -> Self {
        Grid {
            cells: vec![vec![' '; COLS]; ROWS],
            cursor_row: 0,
            cursor_col: 0,
        }
    }

    pub fn put_char(&mut self, ch: char) {
        if ch == '\n' {
            self.cursor_col = 0;
            self.cursor_row = (self.cursor_row + 1).min(ROWS - 1);
            return;
        }
        if self.cursor_col < COLS && self.cursor_row < ROWS {
            self.cells[self.cursor_row][self.cursor_col] = ch;
            self.cursor_col += 1;
            if self.cursor_col >= COLS {
                self.cursor_col = 0;
                self.cursor_row = (self.cursor_row + 1).min(ROWS - 1);
            }
        }
    }

    pub fn backspace(&mut self) {
        if self.cursor_col > 0 {
            self.cursor_col -= 1;
            self.cells[self.cursor_row][self.cursor_col] = ' ';
        }
    }

    pub fn render_text(&self) -> String {
        self.cells.iter()
            .map(|row| row.iter().collect::<String>())
            .collect::<Vec<_>>()
            .join("\n")
    }
}

#[wasm_bindgen(start)]
pub fn start() -> Result<(), JsValue> {
    let document = web_sys::window().unwrap().document().unwrap();
    let canvas: web_sys::HtmlCanvasElement = document
        .get_element_by_id("canvas").unwrap()
        .dyn_into()?;

    canvas.set_width((COLS as f64 * CELL_W) as u32);
    canvas.set_height((ROWS as f64 * CELL_H) as u32);

    let ctx: web_sys::CanvasRenderingContext2d = canvas
        .get_context("2d")?.unwrap().dyn_into()?;

    let grid = Rc::new(RefCell::new(Grid::new()));

    // Initial render
    render_grid(&ctx, &grid.borrow());

    let grid_clone = grid.clone();
    let cb = Closure::<dyn FnMut(_)>::new(move |event: web_sys::KeyboardEvent| {
        event.prevent_default();
        let key = event.key();
        let mut g = grid_clone.borrow_mut();
        match key.as_str() {
            "Backspace" => g.backspace(),
            "Enter" => g.put_char('\n'),
            s if s.len() == 1 => g.put_char(s.chars().next().unwrap()),
            _ => {}
        }
        let doc = web_sys::window().unwrap().document().unwrap();
        let c: web_sys::HtmlCanvasElement = doc.get_element_by_id("canvas").unwrap().dyn_into().unwrap();
        let context: web_sys::CanvasRenderingContext2d = c.get_context("2d").unwrap().unwrap().dyn_into().unwrap();
        render_grid(&context, &g);
    });

    document.add_event_listener_with_callback("keydown", cb.as_ref().unchecked_ref())?;
    cb.forget();
    Ok(())
}

fn render_grid(ctx: &web_sys::CanvasRenderingContext2d, grid: &Grid) {
    ctx.set_fill_style_str("#1e1e1e");
    ctx.fill_rect(0.0, 0.0, COLS as f64 * CELL_W, ROWS as f64 * CELL_H);
    ctx.set_fill_style_str("#00ff00");
    ctx.set_font("16px monospace");

    for (r, row) in grid.cells.iter().enumerate() {
        for (c, &ch) in row.iter().enumerate() {
            if ch != ' ' {
                ctx.fill_text(
                    &ch.to_string(),
                    c as f64 * CELL_W + 2.0,
                    r as f64 * CELL_H + 16.0,
                ).unwrap();
            }
        }
    }

    // Draw cursor
    ctx.set_fill_style_str("#00ff00");
    ctx.fill_rect(
        grid.cursor_col as f64 * CELL_W,
        grid.cursor_row as f64 * CELL_H,
        2.0,
        CELL_H,
    );
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_grid_new() {
        let g = Grid::new();
        assert_eq!(g.cells.len(), ROWS);
        assert_eq!(g.cells[0].len(), COLS);
    }

    #[test]
    fn test_put_char() {
        let mut g = Grid::new();
        g.put_char('A');
        assert_eq!(g.cells[0][0], 'A');
        assert_eq!(g.cursor_col, 1);
    }

    #[test]
    fn test_backspace() {
        let mut g = Grid::new();
        g.put_char('A');
        g.backspace();
        assert_eq!(g.cells[0][0], ' ');
        assert_eq!(g.cursor_col, 0);
    }

    #[test]
    fn test_newline() {
        let mut g = Grid::new();
        g.put_char('A');
        g.put_char('\n');
        assert_eq!(g.cursor_row, 1);
        assert_eq!(g.cursor_col, 0);
    }

    #[test]
    fn test_render_text() {
        let mut g = Grid::new();
        g.put_char('H');
        g.put_char('i');
        let text = g.render_text();
        assert!(text.starts_with("Hi"));
    }
}
