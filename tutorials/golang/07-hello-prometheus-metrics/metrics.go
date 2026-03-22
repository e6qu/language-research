package main

import (
	"encoding/json"
	"net/http"

	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

var (
	workCounter = prometheus.NewCounter(prometheus.CounterOpts{
		Name: "work_total",
		Help: "Total number of work requests processed.",
	})

	workDuration = prometheus.NewHistogram(prometheus.HistogramOpts{
		Name:    "work_duration_seconds",
		Help:    "Duration of work requests in seconds.",
		Buckets: prometheus.DefBuckets,
	})
)

func init() {
	prometheus.MustRegister(workCounter)
	prometheus.MustRegister(workDuration)
}

type metricsResponse struct {
	Message string `json:"message"`
	Count   string `json:"count,omitempty"`
}

func handleWork(w http.ResponseWriter, r *http.Request) {
	timer := prometheus.NewTimer(workDuration)
	defer timer.ObserveDuration()

	workCounter.Inc()

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(metricsResponse{Message: "work done"})
}

func handleIndex(w http.ResponseWriter, r *http.Request) {
	if r.URL.Path != "/" {
		http.NotFound(w, r)
		return
	}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(metricsResponse{Message: "hello-metrics"})
}

func newMetricsMux() *http.ServeMux {
	mux := http.NewServeMux()
	mux.HandleFunc("/", handleIndex)
	mux.HandleFunc("/work", handleWork)
	mux.Handle("/metrics", promhttp.Handler())
	return mux
}
