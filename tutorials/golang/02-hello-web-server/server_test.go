package main

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestRoutes(t *testing.T) {
	mux := newMux()

	tests := []struct {
		name       string
		path       string
		wantStatus int
		wantMsg    string
	}{
		{"root returns hello", "/", http.StatusOK, "Hello, World!"},
		{"greet by name", "/greet/Gopher", http.StatusOK, "Hello, Gopher!"},
		{"greet another name", "/greet/Alice", http.StatusOK, "Hello, Alice!"},
		{"unknown path is 404", "/unknown", http.StatusNotFound, "not found"},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			req := httptest.NewRequest(http.MethodGet, tt.path, nil)
			rec := httptest.NewRecorder()

			mux.ServeHTTP(rec, req)

			if rec.Code != tt.wantStatus {
				t.Errorf("status = %d, want %d", rec.Code, tt.wantStatus)
			}

			var resp Response
			if err := json.NewDecoder(rec.Body).Decode(&resp); err != nil {
				t.Fatalf("failed to decode JSON: %v", err)
			}
			if resp.Message != tt.wantMsg {
				t.Errorf("message = %q, want %q", resp.Message, tt.wantMsg)
			}

			ct := rec.Header().Get("Content-Type")
			if ct != "application/json" {
				t.Errorf("Content-Type = %q, want application/json", ct)
			}
		})
	}
}
