package main

import (
	"fmt"
	"net/http"
)

func main() {
	dt := NewDependencyTracker()
	dt.Register("database", true, "connected")
	dt.Register("cache", true, "connected")

	mux := newHealthMux(dt)
	addr := ":4063"
	fmt.Printf("Listening on %s\n", addr)
	fmt.Println("  GET /healthz — liveness probe")
	fmt.Println("  GET /readyz  — readiness probe")
	fmt.Println("  GET /health  — detailed health")
	if err := http.ListenAndServe(addr, mux); err != nil {
		fmt.Printf("Error: %v\n", err)
	}
}
