package main

import (
	"encoding/json"
	"fmt"
	"net/http"
	"strings"
)

type greetRequest struct {
	Name string `json:"name"`
}

type greetResponse struct {
	Message string `json:"message"`
}

type errorResponse struct {
	Error string `json:"error"`
}

func writeJSON(w http.ResponseWriter, status int, v any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	json.NewEncoder(w).Encode(v)
}

func handleRoot(w http.ResponseWriter, r *http.Request) {
	if r.URL.Path != "/" {
		writeJSON(w, http.StatusNotFound, errorResponse{Error: "not found"})
		return
	}
	writeJSON(w, http.StatusOK, greetResponse{Message: "Hello, World!"})
}

func handleGreetByName(w http.ResponseWriter, r *http.Request) {
	name := r.PathValue("name")
	if name == "" {
		writeJSON(w, http.StatusBadRequest, errorResponse{Error: "name is required"})
		return
	}
	writeJSON(w, http.StatusOK, greetResponse{Message: fmt.Sprintf("Hello, %s!", name)})
}

func handleGreetPost(w http.ResponseWriter, r *http.Request) {
	var req greetRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeJSON(w, http.StatusBadRequest, errorResponse{Error: "invalid JSON body"})
		return
	}
	if strings.TrimSpace(req.Name) == "" {
		writeJSON(w, http.StatusBadRequest, errorResponse{Error: "name is required"})
		return
	}
	writeJSON(w, http.StatusOK, greetResponse{Message: fmt.Sprintf("Hello, %s!", req.Name)})
}

func handleOpenAPI(w http.ResponseWriter, r *http.Request) {
	spec := BuildSpec()
	writeJSON(w, http.StatusOK, spec)
}

func newMux() *http.ServeMux {
	mux := http.NewServeMux()
	mux.HandleFunc("/", handleRoot)
	mux.HandleFunc("/greet/{name}", handleGreetByName)
	mux.HandleFunc("POST /greet", handleGreetPost)
	mux.HandleFunc("/api/openapi", handleOpenAPI)
	return mux
}
