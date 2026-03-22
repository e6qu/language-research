use axum::{Router, extract::Path, response::Json};
use serde::{Deserialize, Serialize};
use utoipa::{OpenApi, ToSchema};

#[derive(Serialize, Deserialize, ToSchema)]
pub struct Greeting {
    /// The greeting message
    pub message: String,
}

/// Say hello to the world
#[utoipa::path(
    get,
    path = "/",
    responses(
        (status = 200, description = "Greeting", body = Greeting)
    )
)]
pub async fn root() -> Json<Greeting> {
    Json(Greeting {
        message: "Hello, World!".to_string(),
    })
}

/// Greet someone by name
#[utoipa::path(
    get,
    path = "/greet/{name}",
    params(
        ("name" = String, Path, description = "Name to greet")
    ),
    responses(
        (status = 200, description = "Personalized greeting", body = Greeting)
    )
)]
pub async fn greet(Path(name): Path<String>) -> Json<Greeting> {
    Json(Greeting {
        message: format!("Hello, {}!", name),
    })
}

#[derive(OpenApi)]
#[openapi(
    paths(root, greet),
    components(schemas(Greeting))
)]
pub struct ApiDoc;

/// Return the OpenAPI spec as JSON.
pub async fn openapi_json() -> Json<utoipa::openapi::OpenApi> {
    Json(ApiDoc::openapi())
}

pub fn app() -> Router {
    let swagger = utoipa_swagger_ui::SwaggerUi::new("/swagger-ui")
        .url("/api/openapi", ApiDoc::openapi());

    Router::new()
        .route("/", axum::routing::get(root))
        .route("/greet/{name}", axum::routing::get(greet))
        .merge(swagger)
}

#[cfg(test)]
mod tests {
    use super::*;
    use axum::body::Body;
    use axum::http::Request;
    use http_body_util::BodyExt;
    use tower::ServiceExt;

    #[tokio::test]
    async fn test_openapi_spec_is_valid() {
        let app = app();
        let resp = app
            .oneshot(
                Request::builder()
                    .uri("/api/openapi")
                    .body(Body::empty())
                    .unwrap(),
            )
            .await
            .unwrap();
        assert_eq!(resp.status(), 200);
        let body = resp.into_body().collect().await.unwrap().to_bytes();
        let spec: serde_json::Value = serde_json::from_slice(&body).unwrap();
        assert_eq!(spec["openapi"].as_str().unwrap().starts_with("3."), true);
        assert!(spec["paths"]["/"].is_object());
        assert!(spec["paths"]["/greet/{name}"].is_object());
    }

    #[tokio::test]
    async fn test_greeting_endpoint() {
        let app = app();
        let resp = app
            .oneshot(
                Request::builder()
                    .uri("/greet/Rust")
                    .body(Body::empty())
                    .unwrap(),
            )
            .await
            .unwrap();
        assert_eq!(resp.status(), 200);
        let body = resp.into_body().collect().await.unwrap().to_bytes();
        let greeting: Greeting = serde_json::from_slice(&body).unwrap();
        assert_eq!(greeting.message, "Hello, Rust!");
    }
}
