use wasm_bindgen::prelude::*;
use wasm_bindgen_futures::JsFuture;
use js_sys::{Array, Promise};
use web_sys::{Request, RequestInit, RequestMode, Response};

pub fn build_urls(base: &str, ids: &[u32]) -> Vec<String> {
    ids.iter().map(|id| format!("{}/{}", base, id)).collect()
}

pub fn format_results(results: &[String]) -> String {
    results.iter()
        .enumerate()
        .map(|(i, r)| format!("#{}: {}", i + 1, r))
        .collect::<Vec<_>>()
        .join("\n")
}

async fn fetch_text(url: &str) -> Result<String, JsValue> {
    let mut opts = RequestInit::new();
    opts.method("GET");
    opts.mode(RequestMode::Cors);

    let request = Request::new_with_str_and_init(url, &opts)?;
    let window = web_sys::window().unwrap();
    let resp_value = JsFuture::from(window.fetch_with_request(&request)).await?;
    let resp: Response = resp_value.dyn_into()?;
    let text = JsFuture::from(resp.text()?).await?;
    Ok(text.as_string().unwrap_or_default())
}

#[wasm_bindgen]
pub async fn parallel_fetch(base_url: &str, count: u32) -> Result<String, JsValue> {
    let window = web_sys::window().unwrap();
    let perf = window.performance().unwrap();
    let start = perf.now();

    let ids: Vec<u32> = (1..=count).collect();
    let urls = build_urls(base_url, &ids);

    // Create an array of fetch promises
    let promises = Array::new();
    for url in &urls {
        let mut opts = RequestInit::new();
        opts.method("GET");
        opts.mode(RequestMode::Cors);
        let request = Request::new_with_str_and_init(url, &opts)?;
        let promise = window.fetch_with_request(&request);
        promises.push(&promise);
    }

    // Promise.all - parallel execution
    let all = JsFuture::from(Promise::all(&promises)).await?;
    let results_arr: Array = all.dyn_into()?;

    let mut texts = Vec::new();
    for i in 0..results_arr.length() {
        let resp: Response = results_arr.get(i).dyn_into()?;
        let text = JsFuture::from(resp.text()?).await?;
        let s = text.as_string().unwrap_or_default();
        // Extract just the title from JSON
        if let Ok(v) = serde_json::from_str::<serde_json::Value>(&s) {
            texts.push(v["title"].as_str().unwrap_or("?").to_string());
        } else {
            texts.push(s);
        }
    }

    let elapsed = perf.now() - start;
    let output = format!(
        "Fetched {} URLs in {:.0}ms (parallel)\n\n{}",
        count, elapsed, format_results(&texts)
    );

    let document = window.document().unwrap();
    let el = document.get_element_by_id("output").unwrap();
    el.set_text_content(Some(&output));

    Ok(output)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_build_urls() {
        let urls = build_urls("https://api.example.com/items", &[1, 2, 3]);
        assert_eq!(urls.len(), 3);
        assert_eq!(urls[0], "https://api.example.com/items/1");
        assert_eq!(urls[2], "https://api.example.com/items/3");
    }

    #[test]
    fn test_format_results() {
        let results = vec!["alpha".to_string(), "beta".to_string()];
        let formatted = format_results(&results);
        assert_eq!(formatted, "#1: alpha\n#2: beta");
    }

    #[test]
    fn test_format_empty() {
        let results: Vec<String> = vec![];
        assert_eq!(format_results(&results), "");
    }
}
