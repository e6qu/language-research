use serde::{Deserialize, Serialize};
use wasm_bindgen::prelude::*;
use wasm_bindgen_futures::JsFuture;
use web_sys::{Request, RequestInit, RequestMode, Response};

#[derive(Serialize, Deserialize, Debug, Clone, PartialEq)]
#[serde(rename_all = "lowercase")]
pub enum Status {
    Up,
    Down,
    Degraded,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct Check {
    pub name: String,
    pub status: Status,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub message: Option<String>,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct HealthReport {
    pub liveness: Status,
    pub readiness: Status,
    pub checks: Vec<Check>,
}

impl HealthReport {
    pub fn new(checks: Vec<Check>) -> Self {
        let liveness = if checks.iter().any(|c| c.status == Status::Down) {
            Status::Down
        } else {
            Status::Up
        };

        let readiness = if checks.iter().all(|c| c.status == Status::Up) {
            Status::Up
        } else if checks.iter().any(|c| c.status == Status::Down) {
            Status::Down
        } else {
            Status::Degraded
        };

        HealthReport { liveness, readiness, checks }
    }

    pub fn is_healthy(&self) -> bool {
        self.liveness == Status::Up
    }

    pub fn is_ready(&self) -> bool {
        self.readiness == Status::Up
    }
}

pub fn status_emoji(status: &Status) -> &'static str {
    match status {
        Status::Up => "OK",
        Status::Down => "FAIL",
        Status::Degraded => "WARN",
    }
}

pub fn status_color(status: &Status) -> &'static str {
    match status {
        Status::Up => "#4caf50",
        Status::Down => "#f44336",
        Status::Degraded => "#ff9800",
    }
}

pub fn render_html(report: &HealthReport) -> String {
    let mut html = String::new();

    html.push_str(&format!(
        "<div style='display:flex;gap:20px;margin-bottom:20px'>\
         <div class='card' style='background:{}'><h2>Liveness</h2><p>{}</p></div>\
         <div class='card' style='background:{}'><h2>Readiness</h2><p>{}</p></div>\
         </div>",
        status_color(&report.liveness), status_emoji(&report.liveness),
        status_color(&report.readiness), status_emoji(&report.readiness),
    ));

    html.push_str("<h2>Checks</h2>");
    for check in &report.checks {
        html.push_str(&format!(
            "<div class='card' style='background:{};margin-bottom:8px'>\
             <strong>{}</strong>: {} {}</div>",
            status_color(&check.status),
            check.name,
            status_emoji(&check.status),
            check.message.as_deref().unwrap_or(""),
        ));
    }

    html
}

pub fn build_demo_report() -> HealthReport {
    HealthReport::new(vec![
        Check { name: "database".into(), status: Status::Up, message: Some("Connected".into()) },
        Check { name: "cache".into(), status: Status::Degraded, message: Some("High latency".into()) },
        Check { name: "api".into(), status: Status::Up, message: Some("Responding".into()) },
    ])
}

#[wasm_bindgen(start)]
pub fn start() -> Result<(), JsValue> {
    render_report()?;

    // Auto-refresh every 3 seconds simulating polling
    let cb = Closure::<dyn FnMut()>::new(move || {
        let _ = render_report();
    });
    web_sys::window().unwrap()
        .set_interval_with_callback_and_timeout_and_arguments_0(
            cb.as_ref().unchecked_ref(), 3000,
        )?;
    cb.forget();
    Ok(())
}

fn render_report() -> Result<(), JsValue> {
    let report = build_demo_report();
    let html = render_html(&report);

    let window = web_sys::window().unwrap();
    let document = window.document().unwrap();
    let el = document.get_element_by_id("output").unwrap();
    el.set_inner_html(&html);

    // Also show JSON
    let json_el = document.get_element_by_id("json").unwrap();
    json_el.set_text_content(Some(&serde_json::to_string_pretty(&report).unwrap()));

    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_all_up() {
        let report = HealthReport::new(vec![
            Check { name: "a".into(), status: Status::Up, message: None },
            Check { name: "b".into(), status: Status::Up, message: None },
        ]);
        assert!(report.is_healthy());
        assert!(report.is_ready());
    }

    #[test]
    fn test_one_down() {
        let report = HealthReport::new(vec![
            Check { name: "a".into(), status: Status::Up, message: None },
            Check { name: "b".into(), status: Status::Down, message: None },
        ]);
        assert!(!report.is_healthy());
        assert!(!report.is_ready());
    }

    #[test]
    fn test_degraded() {
        let report = HealthReport::new(vec![
            Check { name: "a".into(), status: Status::Up, message: None },
            Check { name: "b".into(), status: Status::Degraded, message: None },
        ]);
        assert!(report.is_healthy());
        assert!(!report.is_ready());
        assert_eq!(report.readiness, Status::Degraded);
    }

    #[test]
    fn test_render_html() {
        let report = build_demo_report();
        let html = render_html(&report);
        assert!(html.contains("Liveness"));
        assert!(html.contains("database"));
        assert!(html.contains("cache"));
    }

    #[test]
    fn test_status_emoji() {
        assert_eq!(status_emoji(&Status::Up), "OK");
        assert_eq!(status_emoji(&Status::Down), "FAIL");
        assert_eq!(status_emoji(&Status::Degraded), "WARN");
    }

    #[test]
    fn test_json_roundtrip() {
        let report = build_demo_report();
        let json = serde_json::to_string(&report).unwrap();
        let parsed: HealthReport = serde_json::from_str(&json).unwrap();
        assert_eq!(parsed.checks.len(), 3);
    }
}
