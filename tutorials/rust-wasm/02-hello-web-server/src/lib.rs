use serde::{Deserialize, Serialize};
use wasm_bindgen::prelude::*;
use wasm_bindgen_futures::JsFuture;
use web_sys::{Request, RequestInit, RequestMode, Response};

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct Todo {
    #[serde(rename = "userId")]
    pub user_id: u32,
    pub id: u32,
    pub title: String,
    pub completed: bool,
}

pub fn format_todo(todo: &Todo) -> String {
    format!(
        "[{}] #{}: {}",
        if todo.completed { "x" } else { " " },
        todo.id,
        todo.title
    )
}

pub fn parse_todo(json: &str) -> Result<Todo, String> {
    serde_json::from_str(json).map_err(|e| e.to_string())
}

#[wasm_bindgen]
pub async fn fetch_and_render(url: &str) -> Result<(), JsValue> {
    let mut opts = RequestInit::new();
    opts.method("GET");
    opts.mode(RequestMode::Cors);

    let request = Request::new_with_str_and_init(url, &opts)?;
    let window = web_sys::window().unwrap();
    let resp_value = JsFuture::from(window.fetch_with_request(&request)).await?;
    let resp: Response = resp_value.dyn_into()?;
    let json = JsFuture::from(resp.text()?).await?;
    let text = json.as_string().unwrap_or_default();
    let todo: Todo = serde_json::from_str(&text).map_err(|e| JsValue::from_str(&e.to_string()))?;

    let document = window.document().unwrap();
    let el = document.get_element_by_id("output").unwrap();
    el.set_text_content(Some(&format_todo(&todo)));
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_format_todo() {
        let todo = Todo { user_id: 1, id: 1, title: "Buy milk".into(), completed: false };
        assert_eq!(format_todo(&todo), "[ ] #1: Buy milk");

        let done = Todo { user_id: 1, id: 2, title: "Done".into(), completed: true };
        assert_eq!(format_todo(&done), "[x] #2: Done");
    }

    #[test]
    fn test_parse_todo() {
        let json = r#"{"userId":1,"id":1,"title":"test","completed":false}"#;
        let todo = parse_todo(json).unwrap();
        assert_eq!(todo.id, 1);
        assert_eq!(todo.title, "test");
    }

    #[test]
    fn test_parse_invalid() {
        assert!(parse_todo("not json").is_err());
    }
}
