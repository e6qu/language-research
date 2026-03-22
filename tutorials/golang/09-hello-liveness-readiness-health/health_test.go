package main

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestHealthzAlwaysOK(t *testing.T) {
	req := httptest.NewRequest(http.MethodGet, "/healthz", nil)
	rec := httptest.NewRecorder()

	HandleHealthz(rec, req)

	if rec.Code != http.StatusOK {
		t.Errorf("status = %d, want 200", rec.Code)
	}

	var resp map[string]string
	json.NewDecoder(rec.Body).Decode(&resp)
	if resp["status"] != "alive" {
		t.Errorf("status = %q, want 'alive'", resp["status"])
	}
}

func TestReadyzAllHealthy(t *testing.T) {
	dt := NewDependencyTracker()
	dt.Register("db", true, "ok")
	dt.Register("cache", true, "ok")

	handler := HandleReadyz(dt)
	req := httptest.NewRequest(http.MethodGet, "/readyz", nil)
	rec := httptest.NewRecorder()

	handler(rec, req)

	if rec.Code != http.StatusOK {
		t.Errorf("status = %d, want 200", rec.Code)
	}

	var resp map[string]string
	json.NewDecoder(rec.Body).Decode(&resp)
	if resp["status"] != "ready" {
		t.Errorf("status = %q, want 'ready'", resp["status"])
	}
}

func TestReadyzUnhealthy(t *testing.T) {
	dt := NewDependencyTracker()
	dt.Register("db", false, "connection refused")

	handler := HandleReadyz(dt)
	req := httptest.NewRequest(http.MethodGet, "/readyz", nil)
	rec := httptest.NewRecorder()

	handler(rec, req)

	if rec.Code != http.StatusServiceUnavailable {
		t.Errorf("status = %d, want 503", rec.Code)
	}
}

func TestHealthDetailed(t *testing.T) {
	dt := NewDependencyTracker()
	dt.Register("db", true, "connected")
	dt.Register("cache", false, "timeout")

	handler := HandleHealth(dt)
	req := httptest.NewRequest(http.MethodGet, "/health", nil)
	rec := httptest.NewRecorder()

	handler(rec, req)

	if rec.Code != http.StatusServiceUnavailable {
		t.Errorf("status = %d, want 503", rec.Code)
	}

	var resp HealthResponse
	if err := json.NewDecoder(rec.Body).Decode(&resp); err != nil {
		t.Fatalf("invalid JSON: %v", err)
	}

	if resp.Status != "unhealthy" {
		t.Errorf("status = %q, want 'unhealthy'", resp.Status)
	}
	if len(resp.Dependencies) != 2 {
		t.Errorf("deps count = %d, want 2", len(resp.Dependencies))
	}
}

func TestHealthAllGood(t *testing.T) {
	dt := NewDependencyTracker()
	dt.Register("db", true, "ok")

	handler := HandleHealth(dt)
	req := httptest.NewRequest(http.MethodGet, "/health", nil)
	rec := httptest.NewRecorder()

	handler(rec, req)

	if rec.Code != http.StatusOK {
		t.Errorf("status = %d, want 200", rec.Code)
	}

	var resp HealthResponse
	json.NewDecoder(rec.Body).Decode(&resp)
	if resp.Status != "healthy" {
		t.Errorf("status = %q, want 'healthy'", resp.Status)
	}
}

func TestDependencyTracker(t *testing.T) {
	dt := NewDependencyTracker()

	// Empty tracker is healthy
	if !dt.AllHealthy() {
		t.Error("empty tracker should be healthy")
	}

	dt.Register("db", true, "ok")
	if !dt.AllHealthy() {
		t.Error("should be healthy with one good dep")
	}

	dt.Register("cache", false, "down")
	if dt.AllHealthy() {
		t.Error("should be unhealthy with one bad dep")
	}

	// Update cache to healthy
	dt.Register("cache", true, "reconnected")
	if !dt.AllHealthy() {
		t.Error("should be healthy after fix")
	}

	deps := dt.List()
	if len(deps) != 2 {
		t.Errorf("deps count = %d, want 2", len(deps))
	}
}

func TestMuxIntegration(t *testing.T) {
	dt := NewDependencyTracker()
	dt.Register("db", true, "ok")
	mux := newHealthMux(dt)

	paths := []struct {
		path       string
		wantStatus int
	}{
		{"/healthz", 200},
		{"/readyz", 200},
		{"/health", 200},
	}

	for _, tt := range paths {
		t.Run(tt.path, func(t *testing.T) {
			req := httptest.NewRequest(http.MethodGet, tt.path, nil)
			rec := httptest.NewRecorder()
			mux.ServeHTTP(rec, req)

			if rec.Code != tt.wantStatus {
				t.Errorf("%s: status = %d, want %d", tt.path, rec.Code, tt.wantStatus)
			}

			// Verify JSON
			var m map[string]any
			if err := json.NewDecoder(rec.Body).Decode(&m); err != nil {
				t.Errorf("%s: invalid JSON: %v", tt.path, err)
			}
		})
	}
}
