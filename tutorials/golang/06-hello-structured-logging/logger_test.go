package main

import (
	"bytes"
	"encoding/json"
	"errors"
	"strings"
	"testing"
)

func TestLogOutputIsValidJSON(t *testing.T) {
	var buf bytes.Buffer
	logger := NewJSONLogger(&buf)

	LogStartup(logger, "test-svc", "0.1.0", ":9090")
	LogRequest(logger, "GET", "/", 200, 1.5)
	LogError(logger, "something broke", errors.New("oops"))

	lines := strings.Split(strings.TrimSpace(buf.String()), "\n")
	if len(lines) != 3 {
		t.Fatalf("expected 3 log lines, got %d", len(lines))
	}

	for i, line := range lines {
		var m map[string]any
		if err := json.Unmarshal([]byte(line), &m); err != nil {
			t.Errorf("line %d is not valid JSON: %v\nline: %s", i, err, line)
		}
	}
}

func TestLogStartupFields(t *testing.T) {
	var buf bytes.Buffer
	logger := NewJSONLogger(&buf)

	LogStartup(logger, "my-svc", "2.0.0", ":3000")

	var m map[string]any
	if err := json.Unmarshal(buf.Bytes(), &m); err != nil {
		t.Fatalf("invalid JSON: %v", err)
	}

	checks := map[string]string{
		"service": "my-svc",
		"version": "2.0.0",
		"addr":    ":3000",
		"msg":     "startup",
	}
	for key, want := range checks {
		got, ok := m[key].(string)
		if !ok || got != want {
			t.Errorf("field %q = %q, want %q", key, got, want)
		}
	}
}

func TestLogRequestFields(t *testing.T) {
	var buf bytes.Buffer
	logger := NewJSONLogger(&buf)

	LogRequest(logger, "POST", "/api", 201, 42.5)

	var m map[string]any
	if err := json.Unmarshal(buf.Bytes(), &m); err != nil {
		t.Fatalf("invalid JSON: %v", err)
	}

	if m["method"] != "POST" {
		t.Errorf("method = %v, want POST", m["method"])
	}
	if m["path"] != "/api" {
		t.Errorf("path = %v, want /api", m["path"])
	}
	// JSON numbers are float64
	if m["status"] != float64(201) {
		t.Errorf("status = %v, want 201", m["status"])
	}
}

func TestLogErrorFields(t *testing.T) {
	var buf bytes.Buffer
	logger := NewJSONLogger(&buf)

	LogError(logger, "db failed", errors.New("timeout"))

	var m map[string]any
	if err := json.Unmarshal(buf.Bytes(), &m); err != nil {
		t.Fatalf("invalid JSON: %v", err)
	}

	if m["msg"] != "db failed" {
		t.Errorf("msg = %v, want 'db failed'", m["msg"])
	}
	if m["error"] != "timeout" {
		t.Errorf("error = %v, want 'timeout'", m["error"])
	}
	if m["level"] != "ERROR" {
		t.Errorf("level = %v, want ERROR", m["level"])
	}
}
