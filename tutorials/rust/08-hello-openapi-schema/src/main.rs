use hello_openapi_schema::app;
use tokio::net::TcpListener;

#[tokio::main]
async fn main() {
    let listener = TcpListener::bind("0.0.0.0:4052").await.unwrap();
    println!("Listening on http://0.0.0.0:4052");
    println!("  Swagger UI: http://0.0.0.0:4052/swagger-ui");
    println!("  OpenAPI JSON: http://0.0.0.0:4052/api/openapi");
    axum::serve(listener, app()).await.unwrap();
}
