use axum::{
    Router,
    extract::State,
    http::StatusCode,
    response::Json,
};
use serde::{Deserialize, Serialize};
use std::sync::{Arc, RwLock};

#[derive(Clone, Serialize, Deserialize)]
pub struct DependencyStatus {
    pub name: String,
    pub healthy: bool,
}

#[derive(Clone)]
pub struct AppState {
    pub dependencies: Arc<RwLock<Vec<DependencyStatus>>>,
    pub ready: Arc<RwLock<bool>>,
}

impl AppState {
    pub fn new(deps: Vec<(&str, bool)>) -> Self {
        Self {
            dependencies: Arc::new(RwLock::new(
                deps.into_iter()
                    .map(|(name, healthy)| DependencyStatus {
                        name: name.to_string(),
                        healthy,
                    })
                    .collect(),
            )),
            ready: Arc::new(RwLock::new(true)),
        }
    }

    pub fn set_ready(&self, val: bool) {
        *self.ready.write().unwrap() = val;
    }

    pub fn set_dep_health(&self, name: &str, healthy: bool) {
        let mut deps = self.dependencies.write().unwrap();
        if let Some(dep) = deps.iter_mut().find(|d| d.name == name) {
            dep.healthy = healthy;
        }
    }
}

#[derive(Serialize, Deserialize)]
pub struct HealthResponse {
    pub status: String,
    pub dependencies: Vec<DependencyStatus>,
}

#[derive(Serialize, Deserialize)]
pub struct SimpleStatus {
    pub status: String,
}

/// Liveness: is the process alive? Always 200 if the server is running.
pub async fn healthz() -> Json<SimpleStatus> {
    Json(SimpleStatus {
        status: "alive".to_string(),
    })
}

/// Readiness: is the service ready to accept traffic?
pub async fn readyz(State(state): State<AppState>) -> (StatusCode, Json<SimpleStatus>) {
    let ready = *state.ready.read().unwrap();
    if ready {
        (StatusCode::OK, Json(SimpleStatus { status: "ready".to_string() }))
    } else {
        (StatusCode::SERVICE_UNAVAILABLE, Json(SimpleStatus { status: "not ready".to_string() }))
    }
}

/// Health: detailed dependency health check.
pub async fn health(State(state): State<AppState>) -> (StatusCode, Json<HealthResponse>) {
    let deps = state.dependencies.read().unwrap().clone();
    let all_healthy = deps.iter().all(|d| d.healthy);
    let status = if all_healthy { "healthy" } else { "unhealthy" };
    let code = if all_healthy {
        StatusCode::OK
    } else {
        StatusCode::SERVICE_UNAVAILABLE
    };
    (
        code,
        Json(HealthResponse {
            status: status.to_string(),
            dependencies: deps,
        }),
    )
}

pub fn app(state: AppState) -> Router {
    Router::new()
        .route("/healthz", axum::routing::get(healthz))
        .route("/readyz", axum::routing::get(readyz))
        .route("/health", axum::routing::get(health))
        .with_state(state)
}

#[cfg(test)]
mod tests {
    use super::*;
    use axum::body::Body;
    use axum::http::Request;
    use http_body_util::BodyExt;
    use tower::ServiceExt;

    fn test_state() -> AppState {
        AppState::new(vec![("database", true), ("cache", true)])
    }

    #[tokio::test]
    async fn test_healthz_always_alive() {
        let app = app(test_state());
        let resp = app
            .oneshot(Request::builder().uri("/healthz").body(Body::empty()).unwrap())
            .await
            .unwrap();
        assert_eq!(resp.status(), StatusCode::OK);
        let body = resp.into_body().collect().await.unwrap().to_bytes();
        let status: SimpleStatus = serde_json::from_slice(&body).unwrap();
        assert_eq!(status.status, "alive");
    }

    #[tokio::test]
    async fn test_readyz_when_ready() {
        let app = app(test_state());
        let resp = app
            .oneshot(Request::builder().uri("/readyz").body(Body::empty()).unwrap())
            .await
            .unwrap();
        assert_eq!(resp.status(), StatusCode::OK);
    }

    #[tokio::test]
    async fn test_readyz_when_not_ready() {
        let state = test_state();
        state.set_ready(false);
        let app = app(state);
        let resp = app
            .oneshot(Request::builder().uri("/readyz").body(Body::empty()).unwrap())
            .await
            .unwrap();
        assert_eq!(resp.status(), StatusCode::SERVICE_UNAVAILABLE);
    }

    #[tokio::test]
    async fn test_health_all_healthy() {
        let app = app(test_state());
        let resp = app
            .oneshot(Request::builder().uri("/health").body(Body::empty()).unwrap())
            .await
            .unwrap();
        assert_eq!(resp.status(), StatusCode::OK);
        let body = resp.into_body().collect().await.unwrap().to_bytes();
        let health: HealthResponse = serde_json::from_slice(&body).unwrap();
        assert_eq!(health.status, "healthy");
        assert_eq!(health.dependencies.len(), 2);
    }

    #[tokio::test]
    async fn test_health_degraded() {
        let state = test_state();
        state.set_dep_health("cache", false);
        let app = app(state);
        let resp = app
            .oneshot(Request::builder().uri("/health").body(Body::empty()).unwrap())
            .await
            .unwrap();
        assert_eq!(resp.status(), StatusCode::SERVICE_UNAVAILABLE);
        let body = resp.into_body().collect().await.unwrap().to_bytes();
        let health: HealthResponse = serde_json::from_slice(&body).unwrap();
        assert_eq!(health.status, "unhealthy");
    }
}
