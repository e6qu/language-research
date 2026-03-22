module hello_logging;
import std::io;

fn int main(String[] args) {
    log_info("Application starting", "main");
    log_debug("Parsing arguments", "cli");
    log_info("Hello, C3!", "greeter");
    log_warn("This is a demo warning", "greeter");
    log_error("Simulated error for demonstration", "greeter");
    log_info("Application shutting down", "main");
    return 0;
}
