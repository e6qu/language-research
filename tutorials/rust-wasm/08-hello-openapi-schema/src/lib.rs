use serde::{Deserialize, Serialize};
use std::collections::BTreeMap;
use wasm_bindgen::prelude::*;

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct OpenApiSpec {
    pub openapi: String,
    pub info: Info,
    pub paths: BTreeMap<String, PathItem>,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct Info {
    pub title: String,
    pub version: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub description: Option<String>,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct PathItem {
    #[serde(skip_serializing_if = "Option::is_none")]
    pub get: Option<Operation>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub post: Option<Operation>,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct Operation {
    pub summary: String,
    #[serde(rename = "operationId")]
    pub operation_id: String,
    pub responses: BTreeMap<String, ResponseObj>,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct ResponseObj {
    pub description: String,
}

impl OpenApiSpec {
    pub fn new(title: &str, version: &str) -> Self {
        OpenApiSpec {
            openapi: "3.0.3".to_string(),
            info: Info {
                title: title.to_string(),
                version: version.to_string(),
                description: None,
            },
            paths: BTreeMap::new(),
        }
    }

    pub fn add_get(&mut self, path: &str, summary: &str, op_id: &str) {
        let mut responses = BTreeMap::new();
        responses.insert("200".to_string(), ResponseObj { description: "OK".to_string() });
        let op = Operation {
            summary: summary.to_string(),
            operation_id: op_id.to_string(),
            responses,
        };
        self.paths.entry(path.to_string())
            .or_insert(PathItem { get: None, post: None })
            .get = Some(op);
    }

    pub fn add_post(&mut self, path: &str, summary: &str, op_id: &str) {
        let mut responses = BTreeMap::new();
        responses.insert("201".to_string(), ResponseObj { description: "Created".to_string() });
        let op = Operation {
            summary: summary.to_string(),
            operation_id: op_id.to_string(),
            responses,
        };
        self.paths.entry(path.to_string())
            .or_insert(PathItem { get: None, post: None })
            .post = Some(op);
    }

    pub fn to_json(&self) -> String {
        serde_json::to_string_pretty(self).unwrap()
    }
}

pub fn parse_spec(json: &str) -> Result<OpenApiSpec, String> {
    serde_json::from_str(json).map_err(|e| e.to_string())
}

pub fn build_sample_spec() -> OpenApiSpec {
    let mut spec = OpenApiSpec::new("Pet Store API", "1.0.0");
    spec.info.description = Some("A sample pet store API".to_string());
    spec.add_get("/pets", "List all pets", "listPets");
    spec.add_post("/pets", "Create a pet", "createPet");
    spec.add_get("/pets/{petId}", "Get a pet by ID", "getPet");
    spec
}

#[wasm_bindgen(start)]
pub fn start() -> Result<(), JsValue> {
    let spec = build_sample_spec();
    let json = spec.to_json();

    let window = web_sys::window().unwrap();
    let document = window.document().unwrap();
    let el = document.get_element_by_id("output").unwrap();
    el.set_text_content(Some(&json));
    Ok(())
}

#[wasm_bindgen]
pub fn get_spec_json() -> String {
    build_sample_spec().to_json()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_new_spec() {
        let spec = OpenApiSpec::new("Test", "1.0.0");
        assert_eq!(spec.openapi, "3.0.3");
        assert_eq!(spec.info.title, "Test");
        assert!(spec.paths.is_empty());
    }

    #[test]
    fn test_add_get() {
        let mut spec = OpenApiSpec::new("Test", "1.0.0");
        spec.add_get("/items", "List items", "listItems");
        assert!(spec.paths.contains_key("/items"));
        assert!(spec.paths["/items"].get.is_some());
    }

    #[test]
    fn test_add_post() {
        let mut spec = OpenApiSpec::new("Test", "1.0.0");
        spec.add_post("/items", "Create item", "createItem");
        let post = spec.paths["/items"].post.as_ref().unwrap();
        assert_eq!(post.operation_id, "createItem");
        assert!(post.responses.contains_key("201"));
    }

    #[test]
    fn test_roundtrip() {
        let spec = build_sample_spec();
        let json = spec.to_json();
        let parsed = parse_spec(&json).unwrap();
        assert_eq!(parsed.info.title, "Pet Store API");
        assert_eq!(parsed.paths.len(), 2);
    }

    #[test]
    fn test_json_contains_openapi_version() {
        let spec = build_sample_spec();
        let json = spec.to_json();
        assert!(json.contains("\"openapi\": \"3.0.3\""));
    }
}
