/// Application model holding the selectable list state.
pub struct App {
    pub items: Vec<String>,
    pub selected: usize,
    pub should_quit: bool,
}

impl App {
    pub fn new(items: Vec<String>) -> Self {
        Self {
            items,
            selected: 0,
            should_quit: false,
        }
    }

    pub fn move_up(&mut self) {
        if self.selected > 0 {
            self.selected -= 1;
        }
    }

    pub fn move_down(&mut self) {
        if self.selected + 1 < self.items.len() {
            self.selected += 1;
        }
    }

    pub fn quit(&mut self) {
        self.should_quit = true;
    }

    pub fn selected_item(&self) -> Option<&str> {
        self.items.get(self.selected).map(|s| s.as_str())
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn sample_app() -> App {
        App::new(vec![
            "Alpha".into(),
            "Beta".into(),
            "Gamma".into(),
        ])
    }

    #[test]
    fn test_initial_selection() {
        let app = sample_app();
        assert_eq!(app.selected, 0);
        assert_eq!(app.selected_item(), Some("Alpha"));
    }

    #[test]
    fn test_move_down() {
        let mut app = sample_app();
        app.move_down();
        assert_eq!(app.selected, 1);
        assert_eq!(app.selected_item(), Some("Beta"));
    }

    #[test]
    fn test_move_up_at_top() {
        let mut app = sample_app();
        app.move_up();
        assert_eq!(app.selected, 0);
    }

    #[test]
    fn test_move_down_at_bottom() {
        let mut app = sample_app();
        app.move_down();
        app.move_down();
        app.move_down(); // should not go past last
        assert_eq!(app.selected, 2);
    }

    #[test]
    fn test_quit() {
        let mut app = sample_app();
        assert!(!app.should_quit);
        app.quit();
        assert!(app.should_quit);
    }
}
