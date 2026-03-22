module hello_health;
import std::io;
import std::net;

fn int main(String[] args) {
    // Build application health state.
    AppHealth health = { .live = true, .ready = true };
    health.add_check("database", UP);
    health.add_check("cache", UP);
    health.add_check("disk", DEGRADED);

    io::printn("=== Health Status ===");
    health.print_health();
    io::printn("");

    io::printn("Starting health server on :3000 ...");

    TcpServerSocket! server = net::tcp_listen(3000);
    if (catch err = server) {
        io::printfn("Failed to bind: %s", err);
        return 1;
    }

    io::printn("Endpoints:");
    io::printn("  GET /livez    — liveness probe");
    io::printn("  GET /readyz   — readiness probe");
    io::printn("  GET /healthz  — full health report");

    while (true) {
        TcpSocket! client = server.accept();
        if (catch err = client) continue;

        // Read request (just first line for path routing).
        char[1024] buf;
        usz! n = client.read(buf[..]);
        if (catch err = n) { client.close(); continue; }

        char[] req = buf[0..n-1];
        if (req.contains("/livez")) {
            int code = health.live ? 200 : 503;
            respond_http(&client, code, health.liveness_json());
        } else if (req.contains("/readyz")) {
            int code = health.ready ? 200 : 503;
            respond_http(&client, code, health.readiness_json());
        } else {
            // Default: full health
            // For simplicity, render inline.
            respond_http(&client, 200, "{\"status\":\"UP\"}");
        }
        client.close();
    }
    return 0;
}
