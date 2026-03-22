import hello;
import std.stdio;

void main() {
    auto r = newRegistry();
    r = addCounter(r, "http_requests_total", "Total HTTP requests");
    r = addCounter(r, "http_errors_total", "Total HTTP errors");
    r = addGauge(r, "active_connections", "Current active connections");
    r = addGauge(r, "uptime_seconds", "Process uptime in seconds");

    // Simulate some activity
    r = incrementCounter(r, "http_requests_total", 42);
    r = incrementCounter(r, "http_errors_total", 3);
    r = setGauge(r, "active_connections", 7);
    r = setGauge(r, "uptime_seconds", 3600);

    writeln(toPrometheus(r));
}
