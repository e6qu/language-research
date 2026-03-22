package main

import (
	"fmt"
	"net/http"
)

func main() {
	mux := newMetricsMux()
	addr := ":4061"
	fmt.Printf("Listening on %s\n", addr)
	fmt.Println("  GET /        — index")
	fmt.Println("  GET /work    — do work (increments counter)")
	fmt.Println("  GET /metrics — Prometheus metrics")
	if err := http.ListenAndServe(addr, mux); err != nil {
		fmt.Printf("Error: %v\n", err)
	}
}
