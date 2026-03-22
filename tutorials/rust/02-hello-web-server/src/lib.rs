use axum::{
    Router,
    extract::Path,
    http::StatusCode,
    response::Json,
};
use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize)]
pub struct Message {
    pub message: String,
}

pub async fn root() -> Json<Message> {
    Json(Message {
        message: "Hello, World!".to_string(),
    })
}

pub async fn greet(Path(name): Path<String>) -> Json<Message> {
    Json(Message {
        message: format!("Hello, {}!", name),
    })
}

pub async fn fallback() -> (StatusCode, Json<Message>) {
    (
        StatusCode::NOT_FOUND,
        Json(Message {
            message: "Not found".to_string(),
        }),
    )
}

pub fn app() -> Router {
    Router::new()
        .route("/", axum::routing::get(root))
        .route("/greet/{name}", axum::routing::get(greet))
        .fallback(fallback)
}

#[cfg(test)]
mod tests {
    use super::*;
    use axum::body::Body;
    use axum::http::Request;
    use http_body_util::BodyExt;
    use tower::ServiceExt;

    #[tokio::test]
    async fn test_root() {
        let app = app();
        let resp = app
            .oneshot(Request::builder().uri("/").body(Body::empty()).unwrap())
            .await
            .unwrap();
        assert_eq!(resp.status(), StatusCode::OK);
        let body = resp.into_body().collect().await.unwrap().to_bytes();
        let msg: Message = serde_json::from_slice(&body).unwrap();
        assert_eq!(msg.message, "Hello, World!");
    }

    #[tokio::test]
    async fn test_greet() {
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
        assert_eq!(resp.status(), StatusCode::OK);
        let body = resp.into_body().collect().await.unwrap().to_bytes();
        let msg: Message = serde_json::from_slice(&body).unwrap();
        assert_eq!(msg.message, "Hello, Rust!");
    }

    #[tokio::test]
    async fn test_fallback() {
        let app = app();
        let resp = app
            .oneshot(
                Request::builder()
                    .uri("/nonexistent")
                    .body(Body::empty())
                    .unwrap(),
            )
            .await
            .unwrap();
        assert_eq!(resp.status(), StatusCode::NOT_FOUND);
    }
}
