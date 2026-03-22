package main

import (
	"fmt"
	"net/http"
	"time"
)

func main() {
	urls := []string{
		"https://httpbin.org/delay/1",
		"https://httpbin.org/delay/1",
		"https://httpbin.org/delay/1",
		"https://httpbin.org/status/404",
		"https://httpbin.org/get",
	}

	client := &http.Client{Timeout: 10 * time.Second}

	fmt.Printf("Fetching %d URLs concurrently...\n", len(urls))
	start := time.Now()
	results := FetchAll(urls, client)
	total := time.Since(start)

	PrintResults(results)
	fmt.Printf("\nTotal time: %s (sequential would be ~%ds)\n", total, len(urls))
}
