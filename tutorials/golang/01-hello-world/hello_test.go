package main

import "testing"

func TestGreet(t *testing.T) {
	tests := []struct {
		name     string
		input    string
		expected string
	}{
		{"empty name defaults to World", "", "Hello, World!"},
		{"greets by name", "Go", "Hello, Go!"},
		{"greets Gopher", "Gopher", "Hello, Gopher!"},
		{"greets with spaces", "Jane Doe", "Hello, Jane Doe!"},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got := Greet(tt.input)
			if got != tt.expected {
				t.Errorf("Greet(%q) = %q, want %q", tt.input, got, tt.expected)
			}
		})
	}
}
