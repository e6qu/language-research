use hello_prometheus_metrics::app;
use tokio::net::TcpListener;

#[tokio::main]
async fn main() {
    let listener = TcpListener::bind("0.0.0.0:4051").await.unwrap();
    println!("Listening on http://0.0.0.0:4051");
    println!("  POST /work     - do work (increments counter)");
    println!("  GET  /metrics  - prometheus metrics");
    axum::serve(listener, app()).await.unwrap();
}
