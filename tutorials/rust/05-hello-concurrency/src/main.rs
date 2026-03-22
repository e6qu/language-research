use hello_concurrency::fetch_all;

#[tokio::main]
async fn main() {
    let urls = vec![
        "https://httpbin.org/get".to_string(),
        "https://httpbin.org/ip".to_string(),
        "https://httpbin.org/user-agent".to_string(),
    ];

    println!("Fetching {} URLs concurrently...", urls.len());
    let results = fetch_all(urls).await;

    for result in results {
        match result {
            Ok(r) => println!("  {} -> {} ({} bytes)", r.url, r.status, r.size),
            Err(e) => println!("  Error: {}", e),
        }
    }
}
