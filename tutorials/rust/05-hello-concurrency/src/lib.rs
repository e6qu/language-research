use std::time::Duration;
use tokio::task::JoinHandle;

/// Result of fetching a single URL.
#[derive(Debug)]
pub struct FetchResult {
    pub url: String,
    pub status: u16,
    pub size: usize,
}

/// Fetch a single URL and return its status and body size.
pub async fn fetch_url(client: &reqwest::Client, url: &str) -> Result<FetchResult, String> {
    let resp = client
        .get(url)
        .timeout(Duration::from_secs(10))
        .send()
        .await
        .map_err(|e| format!("{}: {}", url, e))?;
    let status = resp.status().as_u16();
    let body = resp.text().await.map_err(|e| format!("{}: {}", url, e))?;
    Ok(FetchResult {
        url: url.to_string(),
        status,
        size: body.len(),
    })
}

/// Fetch multiple URLs concurrently using tokio::spawn + join_all.
pub async fn fetch_all(urls: Vec<String>) -> Vec<Result<FetchResult, String>> {
    let client = reqwest::Client::new();
    let handles: Vec<JoinHandle<Result<FetchResult, String>>> = urls
        .into_iter()
        .map(|url| {
            let client = client.clone();
            tokio::spawn(async move { fetch_url(&client, &url).await })
        })
        .collect();

    let mut results = Vec::new();
    for handle in futures::future::join_all(handles).await {
        match handle {
            Ok(result) => results.push(result),
            Err(e) => results.push(Err(format!("Task failed: {}", e))),
        }
    }
    results
}

#[cfg(test)]
mod tests {
    use super::*;
    use tokio::net::TcpListener;

    /// Spin up a tiny HTTP server for testing.
    async fn test_server() -> String {
        let listener = TcpListener::bind("127.0.0.1:0").await.unwrap();
        let addr = listener.local_addr().unwrap();
        tokio::spawn(async move {
            loop {
                let (mut stream, _) = listener.accept().await.unwrap();
                tokio::spawn(async move {
                    use tokio::io::{AsyncReadExt, AsyncWriteExt};
                    let mut buf = [0u8; 1024];
                    let _ = stream.read(&mut buf).await;
                    let response = "HTTP/1.1 200 OK\r\nContent-Length: 2\r\n\r\nok";
                    let _ = stream.write_all(response.as_bytes()).await;
                });
            }
        });
        format!("http://{}", addr)
    }

    #[tokio::test]
    async fn test_fetch_url() {
        let url = test_server().await;
        let client = reqwest::Client::new();
        let result = fetch_url(&client, &url).await.unwrap();
        assert_eq!(result.status, 200);
        assert_eq!(result.size, 2);
    }

    #[tokio::test]
    async fn test_fetch_all_concurrent() {
        let url = test_server().await;
        let urls = vec![url.clone(), url.clone(), url.clone()];
        let results = fetch_all(urls).await;
        assert_eq!(results.len(), 3);
        for r in results {
            assert!(r.is_ok());
            assert_eq!(r.unwrap().status, 200);
        }
    }
}
