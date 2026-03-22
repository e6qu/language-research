package main

import (
	"fmt"
	"net/http"
)

func main() {
	mux := newMux()
	addr := ":4062"
	fmt.Printf("Listening on %s\n", addr)
	fmt.Println("  GET  /            — greeting")
	fmt.Println("  GET  /greet/{name} — greet by name")
	fmt.Println("  POST /greet       — greet via JSON body")
	fmt.Println("  GET  /api/openapi — OpenAPI spec")
	if err := http.ListenAndServe(addr, mux); err != nil {
		fmt.Printf("Error: %v\n", err)
	}
}
