use hello_prometheus_metrics::app;
use tokio::net::TcpListener;

#[tokio::main]
async fn main() {
    let listener = TcpListener::bind("0.0.0.0:3000").await.unwrap();
    println!("Listening on http://0.0.0.0:3000");
    println!("  POST /work     - do work (increments counter)");
    println!("  GET  /metrics  - prometheus metrics");
    axum::serve(listener, app()).await.unwrap();
}
