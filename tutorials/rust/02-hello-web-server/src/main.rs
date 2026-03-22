use hello_web_server::app;
use tokio::net::TcpListener;

#[tokio::main]
async fn main() {
    let listener = TcpListener::bind("0.0.0.0:4050").await.unwrap();
    println!("Listening on http://0.0.0.0:4050");
    axum::serve(listener, app()).await.unwrap();
}
