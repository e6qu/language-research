package main

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)

func TestHandleIndex(t *testing.T) {
	mux := newMetricsMux()
	req := httptest.NewRequest(http.MethodGet, "/", nil)
	rec := httptest.NewRecorder()

	mux.ServeHTTP(rec, req)

	if rec.Code != http.StatusOK {
		t.Errorf("status = %d, want 200", rec.Code)
	}

	var resp metricsResponse
	if err := json.NewDecoder(rec.Body).Decode(&resp); err != nil {
		t.Fatalf("invalid JSON: %v", err)
	}
	if resp.Message != "hello-metrics" {
		t.Errorf("message = %q, want 'hello-metrics'", resp.Message)
	}
}

func TestHandleWork(t *testing.T) {
	mux := newMetricsMux()
	req := httptest.NewRequest(http.MethodGet, "/work", nil)
	rec := httptest.NewRecorder()

	mux.ServeHTTP(rec, req)

	if rec.Code != http.StatusOK {
		t.Errorf("status = %d, want 200", rec.Code)
	}

	var resp metricsResponse
	if err := json.NewDecoder(rec.Body).Decode(&resp); err != nil {
		t.Fatalf("invalid JSON: %v", err)
	}
	if resp.Message != "work done" {
		t.Errorf("message = %q, want 'work done'", resp.Message)
	}
}

func TestMetricsEndpoint(t *testing.T) {
	mux := newMetricsMux()

	// Do some work first
	for i := 0; i < 3; i++ {
		req := httptest.NewRequest(http.MethodGet, "/work", nil)
		rec := httptest.NewRecorder()
		mux.ServeHTTP(rec, req)
	}

	// Check metrics
	req := httptest.NewRequest(http.MethodGet, "/metrics", nil)
	rec := httptest.NewRecorder()
	mux.ServeHTTP(rec, req)

	if rec.Code != http.StatusOK {
		t.Errorf("status = %d, want 200", rec.Code)
	}

	body := rec.Body.String()
	if !strings.Contains(body, "work_total") {
		t.Error("metrics output missing work_total")
	}
	if !strings.Contains(body, "work_duration_seconds") {
		t.Error("metrics output missing work_duration_seconds")
	}
}
