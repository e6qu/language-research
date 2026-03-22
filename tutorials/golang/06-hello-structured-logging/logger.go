package main

import (
	"io"
	"log/slog"
)

// NewJSONLogger creates a structured JSON logger writing to w.
func NewJSONLogger(w io.Writer) *slog.Logger {
	return slog.New(slog.NewJSONHandler(w, &slog.HandlerOptions{
		Level: slog.LevelDebug,
	}))
}

// LogRequest logs an HTTP-like request event.
func LogRequest(logger *slog.Logger, method, path string, status int, durationMs float64) {
	logger.Info("request",
		slog.String("method", method),
		slog.String("path", path),
		slog.Int("status", status),
		slog.Float64("duration_ms", durationMs),
	)
}

// LogError logs an error event.
func LogError(logger *slog.Logger, msg string, err error) {
	logger.Error(msg,
		slog.String("error", err.Error()),
	)
}

// LogStartup logs a startup event with service metadata.
func LogStartup(logger *slog.Logger, service, version, addr string) {
	logger.Info("startup",
		slog.String("service", service),
		slog.String("version", version),
		slog.String("addr", addr),
	)
}
