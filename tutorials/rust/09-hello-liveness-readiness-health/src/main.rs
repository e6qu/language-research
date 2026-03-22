use hello_liveness_readiness_health::{app, AppState};
use tokio::net::TcpListener;

#[tokio::main]
async fn main() {
    let state = AppState::new(vec![("database", true), ("cache", true)]);
    let listener = TcpListener::bind("0.0.0.0:3000").await.unwrap();
    println!("Listening on http://0.0.0.0:3000");
    println!("  GET /healthz - liveness");
    println!("  GET /readyz  - readiness");
    println!("  GET /health  - detailed health");
    axum::serve(listener, app(state)).await.unwrap();
}
