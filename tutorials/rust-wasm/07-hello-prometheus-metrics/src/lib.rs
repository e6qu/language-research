use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use wasm_bindgen::prelude::*;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Counter {
    pub name: String,
    pub help: String,
    pub value: f64,
    pub labels: HashMap<String, String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Gauge {
    pub name: String,
    pub help: String,
    pub value: f64,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Histogram {
    pub name: String,
    pub help: String,
    pub sum: f64,
    pub count: u64,
    pub buckets: Vec<(f64, u64)>,
}

#[derive(Debug, Default)]
pub struct Registry {
    pub counters: Vec<Counter>,
    pub gauges: Vec<Gauge>,
    pub histograms: Vec<Histogram>,
}

impl Registry {
    pub fn new() -> Self {
        Self::default()
    }

    pub fn add_counter(&mut self, name: &str, help: &str, value: f64, labels: HashMap<String, String>) {
        self.counters.push(Counter {
            name: name.to_string(),
            help: help.to_string(),
            value,
            labels,
        });
    }

    pub fn add_gauge(&mut self, name: &str, help: &str, value: f64) {
        self.gauges.push(Gauge {
            name: name.to_string(),
            help: help.to_string(),
            value,
        });
    }

    pub fn add_histogram(&mut self, name: &str, help: &str, sum: f64, count: u64, buckets: Vec<(f64, u64)>) {
        self.histograms.push(Histogram {
            name: name.to_string(),
            help: help.to_string(),
            sum,
            count,
            buckets,
        });
    }

    pub fn format_prometheus(&self) -> String {
        let mut out = String::new();

        for c in &self.counters {
            out.push_str(&format!("# HELP {} {}\n", c.name, c.help));
            out.push_str(&format!("# TYPE {} counter\n", c.name));
            if c.labels.is_empty() {
                out.push_str(&format!("{} {}\n", c.name, c.value));
            } else {
                let labels: Vec<String> = c.labels.iter().map(|(k, v)| format!("{}=\"{}\"", k, v)).collect();
                out.push_str(&format!("{}{{{}}} {}\n", c.name, labels.join(","), c.value));
            }
        }

        for g in &self.gauges {
            out.push_str(&format!("# HELP {} {}\n", g.name, g.help));
            out.push_str(&format!("# TYPE {} gauge\n", g.name));
            out.push_str(&format!("{} {}\n", g.name, g.value));
        }

        for h in &self.histograms {
            out.push_str(&format!("# HELP {} {}\n", h.name, h.help));
            out.push_str(&format!("# TYPE {} histogram\n", h.name));
            for (le, count) in &h.buckets {
                out.push_str(&format!("{}_bucket{{le=\"{}\"}} {}\n", h.name, le, count));
            }
            out.push_str(&format!("{}_bucket{{le=\"+Inf\"}} {}\n", h.name, h.count));
            out.push_str(&format!("{}_sum {}\n", h.name, h.sum));
            out.push_str(&format!("{}_count {}\n", h.name, h.count));
        }

        out
    }

    pub fn to_json(&self) -> String {
        serde_json::json!({
            "counters": self.counters,
            "gauges": self.gauges,
            "histograms": self.histograms,
        })
        .to_string()
    }
}

#[wasm_bindgen(start)]
pub fn start() -> Result<(), JsValue> {
    let mut reg = Registry::new();

    let mut labels = HashMap::new();
    labels.insert("method".to_string(), "GET".to_string());
    labels.insert("path".to_string(), "/api/users".to_string());
    reg.add_counter("http_requests_total", "Total HTTP requests", 1027.0, labels);

    reg.add_gauge("memory_usage_bytes", "Current memory usage", 4_521_984.0);
    reg.add_gauge("active_connections", "Active connections", 42.0);

    reg.add_histogram(
        "http_request_duration_seconds",
        "Request duration in seconds",
        5.0, 10,
        vec![(0.005, 3), (0.01, 5), (0.025, 7), (0.05, 8), (0.1, 9), (0.5, 10), (1.0, 10)],
    );

    let prom = reg.format_prometheus();

    let window = web_sys::window().unwrap();
    let document = window.document().unwrap();
    let el = document.get_element_by_id("output").unwrap();
    el.set_text_content(Some(&prom));
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_counter_format() {
        let mut reg = Registry::new();
        reg.add_counter("test_total", "A test counter", 42.0, HashMap::new());
        let out = reg.format_prometheus();
        assert!(out.contains("# TYPE test_total counter"));
        assert!(out.contains("test_total 42"));
    }

    #[test]
    fn test_counter_with_labels() {
        let mut reg = Registry::new();
        let mut labels = HashMap::new();
        labels.insert("method".to_string(), "GET".to_string());
        reg.add_counter("http_total", "HTTP", 10.0, labels);
        let out = reg.format_prometheus();
        assert!(out.contains("method=\"GET\""));
    }

    #[test]
    fn test_gauge_format() {
        let mut reg = Registry::new();
        reg.add_gauge("temp", "Temperature", 36.6);
        let out = reg.format_prometheus();
        assert!(out.contains("# TYPE temp gauge"));
        assert!(out.contains("temp 36.6"));
    }

    #[test]
    fn test_histogram_format() {
        let mut reg = Registry::new();
        reg.add_histogram("dur", "Duration", 1.5, 3, vec![(0.1, 1), (0.5, 2), (1.0, 3)]);
        let out = reg.format_prometheus();
        assert!(out.contains("dur_bucket{le=\"0.1\"} 1"));
        assert!(out.contains("dur_sum 1.5"));
        assert!(out.contains("dur_count 3"));
    }

    #[test]
    fn test_json_output() {
        let mut reg = Registry::new();
        reg.add_gauge("x", "X", 1.0);
        let json = reg.to_json();
        assert!(json.contains("\"name\":\"x\""));
    }
}
