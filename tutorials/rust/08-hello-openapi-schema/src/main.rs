use hello_openapi_schema::app;
use tokio::net::TcpListener;

#[tokio::main]
async fn main() {
    let listener = TcpListener::bind("0.0.0.0:3000").await.unwrap();
    println!("Listening on http://0.0.0.0:3000");
    println!("  Swagger UI: http://0.0.0.0:3000/swagger-ui");
    println!("  OpenAPI JSON: http://0.0.0.0:3000/api/openapi");
    axum::serve(listener, app()).await.unwrap();
}
