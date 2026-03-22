package main

import (
	"fmt"
	"net/http"
)

func main() {
	mux := newMux()
	addr := ":4060"
	fmt.Printf("Listening on %s\n", addr)
	if err := http.ListenAndServe(addr, mux); err != nil {
		fmt.Printf("Error: %v\n", err)
	}
}
