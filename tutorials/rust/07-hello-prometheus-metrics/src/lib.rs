use axum::{Router, response::IntoResponse, http::StatusCode};
use lazy_static::lazy_static;
use prometheus::{IntCounter, TextEncoder, Encoder, register_int_counter};

lazy_static! {
    pub static ref WORK_COUNTER: IntCounter =
        register_int_counter!("work_total", "Total number of work requests").unwrap();
}

pub async fn metrics_handler() -> impl IntoResponse {
    let encoder = TextEncoder::new();
    let metric_families = prometheus::gather();
    let mut buffer = Vec::new();
    encoder.encode(&metric_families, &mut buffer).unwrap();
    (
        StatusCode::OK,
        [("content-type", "text/plain; charset=utf-8")],
        buffer,
    )
}

pub async fn work_handler() -> impl IntoResponse {
    WORK_COUNTER.inc();
    (StatusCode::OK, "work done")
}

pub fn app() -> Router {
    Router::new()
        .route("/metrics", axum::routing::get(metrics_handler))
        .route("/work", axum::routing::post(work_handler))
}

#[cfg(test)]
mod tests {
    use super::*;
    use axum::body::Body;
    use axum::http::Request;
    use http_body_util::BodyExt;
    use tower::ServiceExt;

    #[tokio::test]
    async fn test_work_increments_counter() {
        let app = app();

        // Hit /work
        let resp = app
            .clone()
            .oneshot(
                Request::builder()
                    .method("POST")
                    .uri("/work")
                    .body(Body::empty())
                    .unwrap(),
            )
            .await
            .unwrap();
        assert_eq!(resp.status(), StatusCode::OK);

        // Check /metrics
        let resp = app
            .oneshot(
                Request::builder()
                    .uri("/metrics")
                    .body(Body::empty())
                    .unwrap(),
            )
            .await
            .unwrap();
        assert_eq!(resp.status(), StatusCode::OK);
        let body = resp.into_body().collect().await.unwrap().to_bytes();
        let text = String::from_utf8(body.to_vec()).unwrap();
        assert!(text.contains("work_total"), "Missing work_total metric");
    }
}
