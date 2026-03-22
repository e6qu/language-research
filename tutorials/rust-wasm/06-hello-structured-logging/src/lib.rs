use serde::{Deserialize, Serialize};
use wasm_bindgen::prelude::*;

#[derive(Serialize, Deserialize, Debug, Clone, PartialEq)]
#[serde(rename_all = "UPPERCASE")]
pub enum Level {
    Debug,
    Info,
    Warn,
    Error,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct LogEntry {
    pub level: Level,
    pub message: String,
    pub target: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub fields: Option<serde_json::Value>,
}

impl LogEntry {
    pub fn new(level: Level, target: &str, message: &str) -> Self {
        LogEntry {
            level,
            message: message.to_string(),
            target: target.to_string(),
            fields: None,
        }
    }

    pub fn with_fields(mut self, fields: serde_json::Value) -> Self {
        self.fields = Some(fields);
        self
    }
}

pub fn encode_json(entry: &LogEntry) -> String {
    serde_json::to_string(entry).unwrap_or_else(|e| format!("{{\"error\":\"{}\"}}", e))
}

pub fn encode_pretty(entry: &LogEntry) -> String {
    serde_json::to_string_pretty(entry).unwrap_or_else(|e| format!("{{\"error\":\"{}\"}}", e))
}

#[wasm_bindgen]
pub fn log_to_console(level: &str, target: &str, message: &str) {
    let lvl = match level.to_uppercase().as_str() {
        "DEBUG" => Level::Debug,
        "WARN" => Level::Warn,
        "ERROR" => Level::Error,
        _ => Level::Info,
    };
    let entry = LogEntry::new(lvl, target, message);
    let json = encode_json(&entry);
    web_sys::console::log_1(&JsValue::from_str(&json));
}

#[wasm_bindgen(start)]
pub fn start() -> Result<(), JsValue> {
    let entries = vec![
        LogEntry::new(Level::Info, "app", "Application started"),
        LogEntry::new(Level::Debug, "db", "Connection pool initialized")
            .with_fields(serde_json::json!({"pool_size": 10})),
        LogEntry::new(Level::Warn, "http", "Slow request detected")
            .with_fields(serde_json::json!({"latency_ms": 1500, "path": "/api/users"})),
        LogEntry::new(Level::Error, "auth", "Invalid token"),
    ];

    let mut html = String::from("<pre>");
    for entry in &entries {
        let json = encode_json(entry);
        web_sys::console::log_1(&JsValue::from_str(&json));
        html.push_str(&format!("{}\n", json));
    }
    html.push_str("</pre>");

    let window = web_sys::window().unwrap();
    let document = window.document().unwrap();
    let el = document.get_element_by_id("output").unwrap();
    el.set_inner_html(&html);
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_encode_json() {
        let entry = LogEntry::new(Level::Info, "test", "hello");
        let json = encode_json(&entry);
        assert!(json.contains("\"level\":\"INFO\""));
        assert!(json.contains("\"message\":\"hello\""));
        assert!(json.contains("\"target\":\"test\""));
    }

    #[test]
    fn test_with_fields() {
        let entry = LogEntry::new(Level::Debug, "app", "msg")
            .with_fields(serde_json::json!({"key": "value"}));
        let json = encode_json(&entry);
        assert!(json.contains("\"key\":\"value\""));
    }

    #[test]
    fn test_no_fields_omitted() {
        let entry = LogEntry::new(Level::Warn, "app", "msg");
        let json = encode_json(&entry);
        assert!(!json.contains("fields"));
    }

    #[test]
    fn test_roundtrip() {
        let entry = LogEntry::new(Level::Error, "db", "connection lost");
        let json = encode_json(&entry);
        let parsed: LogEntry = serde_json::from_str(&json).unwrap();
        assert_eq!(parsed.level, Level::Error);
        assert_eq!(parsed.message, "connection lost");
    }
}
