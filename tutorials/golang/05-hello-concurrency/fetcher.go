package main

import (
	"fmt"
	"net/http"
	"sync"
	"time"
)

// FetchResult holds the result of fetching a single URL.
type FetchResult struct {
	URL      string        `json:"url"`
	Status   int           `json:"status"`
	Duration time.Duration `json:"duration"`
	Error    string        `json:"error,omitempty"`
}

// FetchURL fetches a single URL and returns the result.
func FetchURL(url string, client *http.Client) FetchResult {
	start := time.Now()

	resp, err := client.Get(url)
	duration := time.Since(start)

	if err != nil {
		return FetchResult{
			URL:      url,
			Status:   0,
			Duration: duration,
			Error:    err.Error(),
		}
	}
	defer resp.Body.Close()

	return FetchResult{
		URL:      url,
		Status:   resp.StatusCode,
		Duration: duration,
	}
}

// FetchAll fetches all URLs concurrently using goroutines and channels.
func FetchAll(urls []string, client *http.Client) []FetchResult {
	results := make(chan FetchResult, len(urls))
	var wg sync.WaitGroup

	for _, url := range urls {
		wg.Add(1)
		go func(u string) {
			defer wg.Done()
			results <- FetchURL(u, client)
		}(url)
	}

	// Close channel when all goroutines complete
	go func() {
		wg.Wait()
		close(results)
	}()

	// Collect results
	var out []FetchResult
	for r := range results {
		out = append(out, r)
	}
	return out
}

// PrintResults prints fetch results in a readable format.
func PrintResults(results []FetchResult) {
	for _, r := range results {
		if r.Error != "" {
			fmt.Printf("  ✗ %s — error: %s (%s)\n", r.URL, r.Error, r.Duration)
		} else {
			fmt.Printf("  ✓ %s — %d (%s)\n", r.URL, r.Status, r.Duration)
		}
	}
}
