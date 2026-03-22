module hello_health;
import std::io;
import std::net;

enum HealthStatus {
    UP,
    DOWN,
    DEGRADED,
}

fn char[] status_string(HealthStatus s) {
    switch (s) {
        case UP:       return "UP";
        case DOWN:     return "DOWN";
        case DEGRADED: return "DEGRADED";
    }
}

struct HealthCheck {
    char[]       name;
    HealthStatus status;
}

struct AppHealth {
    bool          live;
    bool          ready;
    HealthCheck[8] checks;
    usz           check_count;
}

fn void AppHealth.add_check(AppHealth* self, char[] name, HealthStatus status) {
    if (self.check_count >= 8) return;
    self.checks[self.check_count] = { .name = name, .status = status };
    self.check_count++;
}

fn char[] AppHealth.liveness_json(AppHealth* self) {
    return self.live ? "{\"status\":\"UP\"}" : "{\"status\":\"DOWN\"}";
}

fn char[] AppHealth.readiness_json(AppHealth* self) {
    return self.ready ? "{\"status\":\"UP\"}" : "{\"status\":\"DOWN\"}";
}

fn void AppHealth.print_health(AppHealth* self) {
    io::printn("{");
    io::printfn("  \"live\": %s,", self.live ? "true" : "false");
    io::printfn("  \"ready\": %s,", self.ready ? "true" : "false");
    io::printn("  \"checks\": [");
    for (usz i = 0; i < self.check_count; i++) {
        HealthCheck* c = &self.checks[i];
        char[] comma = (i + 1 < self.check_count) ? "," : "";
        io::printfn("    {\"name\":\"%s\",\"status\":\"%s\"}%s",
            c.name, status_string(c.status), comma);
    }
    io::printn("  ]");
    io::printn("}");
}

fn void respond_http(TcpSocket* client, int code, char[] body) {
    char[] status_text = code == 200 ? "OK" : "Service Unavailable";
    DString header = dstring::temp_new();
    header.appendf(
        "HTTP/1.1 %d %s\r\n"
        "Content-Type: application/json\r\n"
        "Content-Length: %d\r\n"
        "\r\n",
        code, status_text, body.len
    );
    client.write(header.str_view());
    client.write(body);
}
