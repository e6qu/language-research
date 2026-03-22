package main

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)

func TestOpenAPIEndpoint(t *testing.T) {
	mux := newMux()
	req := httptest.NewRequest(http.MethodGet, "/api/openapi", nil)
	rec := httptest.NewRecorder()

	mux.ServeHTTP(rec, req)

	if rec.Code != http.StatusOK {
		t.Errorf("status = %d, want 200", rec.Code)
	}

	var spec OpenAPISpec
	if err := json.NewDecoder(rec.Body).Decode(&spec); err != nil {
		t.Fatalf("invalid JSON: %v", err)
	}

	if spec.OpenAPI != "3.0.3" {
		t.Errorf("openapi = %q, want '3.0.3'", spec.OpenAPI)
	}
	if spec.Info.Title != "Hello API" {
		t.Errorf("title = %q, want 'Hello API'", spec.Info.Title)
	}
	if _, ok := spec.Paths["/"]; !ok {
		t.Error("missing / path")
	}
	if _, ok := spec.Paths["/greet/{name}"]; !ok {
		t.Error("missing /greet/{name} path")
	}
}

func TestGreetByName(t *testing.T) {
	mux := newMux()
	req := httptest.NewRequest(http.MethodGet, "/greet/Gopher", nil)
	rec := httptest.NewRecorder()

	mux.ServeHTTP(rec, req)

	if rec.Code != http.StatusOK {
		t.Errorf("status = %d, want 200", rec.Code)
	}

	var resp greetResponse
	json.NewDecoder(rec.Body).Decode(&resp)
	if resp.Message != "Hello, Gopher!" {
		t.Errorf("message = %q, want 'Hello, Gopher!'", resp.Message)
	}
}

func TestGreetPost(t *testing.T) {
	mux := newMux()

	t.Run("valid body", func(t *testing.T) {
		body := strings.NewReader(`{"name":"Alice"}`)
		req := httptest.NewRequest(http.MethodPost, "/greet", body)
		req.Header.Set("Content-Type", "application/json")
		rec := httptest.NewRecorder()

		mux.ServeHTTP(rec, req)

		if rec.Code != http.StatusOK {
			t.Errorf("status = %d, want 200", rec.Code)
		}
		var resp greetResponse
		json.NewDecoder(rec.Body).Decode(&resp)
		if resp.Message != "Hello, Alice!" {
			t.Errorf("message = %q, want 'Hello, Alice!'", resp.Message)
		}
	})

	t.Run("empty name", func(t *testing.T) {
		body := strings.NewReader(`{"name":""}`)
		req := httptest.NewRequest(http.MethodPost, "/greet", body)
		rec := httptest.NewRecorder()

		mux.ServeHTTP(rec, req)

		if rec.Code != http.StatusBadRequest {
			t.Errorf("status = %d, want 400", rec.Code)
		}
	})

	t.Run("invalid JSON", func(t *testing.T) {
		body := strings.NewReader(`not json`)
		req := httptest.NewRequest(http.MethodPost, "/greet", body)
		rec := httptest.NewRecorder()

		mux.ServeHTTP(rec, req)

		if rec.Code != http.StatusBadRequest {
			t.Errorf("status = %d, want 400", rec.Code)
		}
	})
}

func TestBuildSpec(t *testing.T) {
	spec := BuildSpec()

	// Should marshal to valid JSON
	data, err := json.Marshal(spec)
	if err != nil {
		t.Fatalf("failed to marshal spec: %v", err)
	}

	// Should round-trip
	var parsed OpenAPISpec
	if err := json.Unmarshal(data, &parsed); err != nil {
		t.Fatalf("failed to unmarshal spec: %v", err)
	}

	if parsed.OpenAPI != "3.0.3" {
		t.Errorf("openapi = %q, want '3.0.3'", parsed.OpenAPI)
	}
}
