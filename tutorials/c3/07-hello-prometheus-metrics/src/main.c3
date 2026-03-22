module hello_metrics;
import std::io;

fn int main(String[] args) {
    Registry reg;

    reg.add_counter("http_requests_total", "Total HTTP requests");
    reg.add_counter("greetings_total", "Total greetings served");
    reg.add_gauge("temperature_celsius", "Current temperature", 21.5);

    // Simulate some activity.
    reg.inc("http_requests_total");
    reg.inc("http_requests_total");
    reg.inc("http_requests_total");
    reg.inc("greetings_total");
    reg.set_gauge("temperature_celsius", 22.3);

    io::printn("=== Prometheus Metrics ===\n");
    reg.render();
    return 0;
}
