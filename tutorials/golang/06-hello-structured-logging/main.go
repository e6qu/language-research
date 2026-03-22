package main

import (
	"errors"
	"os"
)

func main() {
	logger := NewJSONLogger(os.Stdout)

	LogStartup(logger, "hello-slog", "1.0.0", ":8080")
	LogRequest(logger, "GET", "/", 200, 1.23)
	LogRequest(logger, "GET", "/greet/Gopher", 200, 0.87)
	LogRequest(logger, "POST", "/unknown", 404, 0.12)
	LogError(logger, "database connection failed", errors.New("connection refused"))
}
