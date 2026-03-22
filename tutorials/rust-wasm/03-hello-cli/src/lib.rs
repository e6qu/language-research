use wasm_bindgen::prelude::*;

#[derive(Debug, PartialEq)]
pub enum Command {
    Help,
    Echo(String),
    Add(f64, f64),
    Clear,
    Unknown(String),
}

pub fn parse_command(input: &str) -> Command {
    let trimmed = input.trim();
    let parts: Vec<&str> = trimmed.splitn(3, ' ').collect();
    match parts.first().map(|s| s.to_lowercase()).as_deref() {
        Some("help") => Command::Help,
        Some("echo") => Command::Echo(parts[1..].join(" ")),
        Some("add") => {
            if parts.len() == 3 {
                if let (Ok(a), Ok(b)) = (parts[1].parse::<f64>(), parts[2].parse::<f64>()) {
                    return Command::Add(a, b);
                }
            }
            Command::Unknown(trimmed.to_string())
        }
        Some("clear") => Command::Clear,
        _ => Command::Unknown(trimmed.to_string()),
    }
}

pub fn execute_command(cmd: &Command) -> String {
    match cmd {
        Command::Help => "Commands: help, echo <text>, add <a> <b>, clear".to_string(),
        Command::Echo(text) => text.clone(),
        Command::Add(a, b) => format!("{}", a + b),
        Command::Clear => "".to_string(),
        Command::Unknown(s) => format!("Unknown command: {}", s),
    }
}

#[wasm_bindgen]
pub fn run_command(input: &str) -> String {
    let cmd = parse_command(input);
    execute_command(&cmd)
}

#[wasm_bindgen(start)]
pub fn start() -> Result<(), JsValue> {
    let window = web_sys::window().unwrap();
    let document = window.document().unwrap();
    let output = document.get_element_by_id("output").unwrap();

    output.set_inner_html("<div class='line'>&gt; Type 'help' and press Enter</div>");

    let cb = Closure::<dyn FnMut(_)>::new(move |event: web_sys::KeyboardEvent| {
        if event.key() == "Enter" {
            let target: web_sys::HtmlInputElement = event.target().unwrap().dyn_into().unwrap();
            let input = target.value();
            let result = run_command(&input);
            let doc = web_sys::window().unwrap().document().unwrap();
            let out = doc.get_element_by_id("output").unwrap();

            if parse_command(&input) == Command::Clear {
                out.set_inner_html("");
            } else {
                let line = doc.create_element("div").unwrap();
                line.set_text_content(Some(&format!("> {} => {}", input, result)));
                out.append_child(&line).unwrap();
            }
            target.set_value("");
        }
    });

    let input_el = document.get_element_by_id("cmd-input").unwrap();
    input_el.add_event_listener_with_callback("keydown", cb.as_ref().unchecked_ref())?;
    cb.forget();
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_parse_help() {
        assert_eq!(parse_command("help"), Command::Help);
    }

    #[test]
    fn test_parse_echo() {
        assert_eq!(parse_command("echo hello world"), Command::Echo("hello world".into()));
    }

    #[test]
    fn test_parse_add() {
        assert_eq!(parse_command("add 2 3"), Command::Add(2.0, 3.0));
    }

    #[test]
    fn test_execute_add() {
        assert_eq!(execute_command(&Command::Add(2.0, 3.0)), "5");
    }

    #[test]
    fn test_execute_help() {
        assert!(execute_command(&Command::Help).contains("help"));
    }

    #[test]
    fn test_unknown() {
        assert_eq!(
            execute_command(&Command::Unknown("foo".into())),
            "Unknown command: foo"
        );
    }
}
