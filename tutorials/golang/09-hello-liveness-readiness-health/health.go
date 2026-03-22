package main

import (
	"encoding/json"
	"net/http"
	"sync"
)

// DependencyStatus represents the health of a single dependency.
type DependencyStatus struct {
	Name    string `json:"name"`
	Healthy bool   `json:"healthy"`
	Message string `json:"message,omitempty"`
}

// HealthResponse is the response for /health.
type HealthResponse struct {
	Status       string             `json:"status"`
	Dependencies []DependencyStatus `json:"dependencies"`
}

// DependencyTracker tracks the health status of dependencies.
type DependencyTracker struct {
	mu   sync.RWMutex
	deps map[string]DependencyStatus
}

// NewDependencyTracker creates a new tracker.
func NewDependencyTracker() *DependencyTracker {
	return &DependencyTracker{
		deps: make(map[string]DependencyStatus),
	}
}

// Register adds or updates a dependency status.
func (dt *DependencyTracker) Register(name string, healthy bool, message string) {
	dt.mu.Lock()
	defer dt.mu.Unlock()
	dt.deps[name] = DependencyStatus{Name: name, Healthy: healthy, Message: message}
}

// AllHealthy returns true if all dependencies are healthy.
func (dt *DependencyTracker) AllHealthy() bool {
	dt.mu.RLock()
	defer dt.mu.RUnlock()
	for _, d := range dt.deps {
		if !d.Healthy {
			return false
		}
	}
	return true
}

// List returns all dependency statuses.
func (dt *DependencyTracker) List() []DependencyStatus {
	dt.mu.RLock()
	defer dt.mu.RUnlock()
	out := make([]DependencyStatus, 0, len(dt.deps))
	for _, d := range dt.deps {
		out = append(out, d)
	}
	return out
}

func writeJSON(w http.ResponseWriter, status int, v any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	json.NewEncoder(w).Encode(v)
}

// HandleHealthz is the liveness probe — always returns 200 if process is running.
func HandleHealthz(w http.ResponseWriter, r *http.Request) {
	writeJSON(w, http.StatusOK, map[string]string{"status": "alive"})
}

// HandleReadyz is the readiness probe — returns 200 only if all deps healthy.
func HandleReadyz(dt *DependencyTracker) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		if dt.AllHealthy() {
			writeJSON(w, http.StatusOK, map[string]string{"status": "ready"})
		} else {
			writeJSON(w, http.StatusServiceUnavailable, map[string]string{"status": "not ready"})
		}
	}
}

// HandleHealth returns detailed health with all dependency statuses.
func HandleHealth(dt *DependencyTracker) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		deps := dt.List()
		status := "healthy"
		httpStatus := http.StatusOK
		if !dt.AllHealthy() {
			status = "unhealthy"
			httpStatus = http.StatusServiceUnavailable
		}
		writeJSON(w, httpStatus, HealthResponse{
			Status:       status,
			Dependencies: deps,
		})
	}
}

func newHealthMux(dt *DependencyTracker) *http.ServeMux {
	mux := http.NewServeMux()
	mux.HandleFunc("/healthz", HandleHealthz)
	mux.HandleFunc("/readyz", HandleReadyz(dt))
	mux.HandleFunc("/health", HandleHealth(dt))
	return mux
}
