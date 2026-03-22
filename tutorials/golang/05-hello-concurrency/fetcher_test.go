package main

import (
	"net/http"
	"net/http/httptest"
	"testing"
	"time"
)

func TestFetchURL(t *testing.T) {
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		w.Write([]byte("ok"))
	}))
	defer server.Close()

	client := &http.Client{Timeout: 5 * time.Second}
	result := FetchURL(server.URL, client)

	if result.Status != 200 {
		t.Errorf("status = %d, want 200", result.Status)
	}
	if result.Error != "" {
		t.Errorf("unexpected error: %s", result.Error)
	}
	if result.URL != server.URL {
		t.Errorf("url = %q, want %q", result.URL, server.URL)
	}
}

func TestFetchURLError(t *testing.T) {
	client := &http.Client{Timeout: 1 * time.Second}
	result := FetchURL("http://localhost:1", client)

	if result.Error == "" {
		t.Error("expected error for bad URL, got none")
	}
	if result.Status != 0 {
		t.Errorf("status = %d, want 0 for error", result.Status)
	}
}

func TestFetchAllConcurrent(t *testing.T) {
	callCount := 0
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		callCount++
		time.Sleep(50 * time.Millisecond)
		w.WriteHeader(http.StatusOK)
	}))
	defer server.Close()

	urls := []string{server.URL, server.URL, server.URL, server.URL, server.URL}
	client := &http.Client{Timeout: 5 * time.Second}

	start := time.Now()
	results := FetchAll(urls, client)
	elapsed := time.Since(start)

	if len(results) != 5 {
		t.Fatalf("got %d results, want 5", len(results))
	}

	for _, r := range results {
		if r.Status != 200 {
			t.Errorf("status = %d, want 200", r.Status)
		}
	}

	// Concurrent fetch of 5 x 50ms should take well under 250ms
	if elapsed > 250*time.Millisecond {
		t.Errorf("took %s, expected concurrent execution under 250ms", elapsed)
	}
}

func TestFetchAllEmpty(t *testing.T) {
	client := &http.Client{}
	results := FetchAll([]string{}, client)
	if len(results) != 0 {
		t.Errorf("expected 0 results, got %d", len(results))
	}
}
