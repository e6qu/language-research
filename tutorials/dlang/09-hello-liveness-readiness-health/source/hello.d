module hello;

import std.json;
import std.format : format;
import std.array : split;
import std.string : startsWith;

struct AppState {
    bool alive;
    bool ready;
    string version_;
    long uptimeSeconds;
    long requestCount;
}

AppState initState() {
    return AppState(true, false, "1.0.0", 0, 0);
}

AppState setReady(AppState s, bool ready) {
    s.ready = ready;
    return s;
}

AppState setAlive(AppState s, bool alive) {
    s.alive = alive;
    return s;
}

AppState incrementRequests(AppState s) {
    s.requestCount++;
    return s;
}

AppState setUptime(AppState s, long seconds) {
    s.uptimeSeconds = seconds;
    return s;
}

struct HttpRequest {
    string method;
    string path;
}

struct HttpResponse {
    int statusCode;
    string contentType;
    string body_;
}

HttpRequest parseRequest(string raw) {
    auto lines = raw.split("\r\n");
    if (lines.length == 0) return HttpRequest("", "");
    auto parts = lines[0].split(" ");
    if (parts.length < 2) return HttpRequest("", "");
    return HttpRequest(parts[0], parts[1]);
}

HttpResponse handleRequest(HttpRequest req, AppState state) {
    if (req.path == "/livez") {
        if (state.alive) {
            return HttpResponse(200, "application/json", `{"status":"alive"}`);
        }
        return HttpResponse(503, "application/json", `{"status":"dead"}`);
    }

    if (req.path == "/readyz") {
        if (state.ready) {
            return HttpResponse(200, "application/json", `{"status":"ready"}`);
        }
        return HttpResponse(503, "application/json", `{"status":"not_ready"}`);
    }

    if (req.path == "/healthz") {
        JSONValue j = parseJSON("{}");
        j["alive"] = state.alive;
        j["ready"] = state.ready;
        j["version"] = state.version_;
        j["uptime_seconds"] = state.uptimeSeconds;
        j["request_count"] = state.requestCount;
        if (state.alive && state.ready) {
            return HttpResponse(200, "application/json", j.toString());
        }
        return HttpResponse(503, "application/json", j.toString());
    }

    if (req.path == "/") {
        return HttpResponse(200, "text/plain", "Hello, world!");
    }

    return HttpResponse(404, "text/plain", "Not Found");
}

string formatResponse(HttpResponse resp) {
    string status = resp.statusCode == 200 ? "OK"
        : resp.statusCode == 503 ? "Service Unavailable"
        : resp.statusCode == 404 ? "Not Found" : "Unknown";
    return format!"HTTP/1.1 %d %s\r\nContent-Type: %s\r\nContent-Length: %d\r\nConnection: close\r\n\r\n%s"(
        resp.statusCode, status, resp.contentType, resp.body_.length, resp.body_);
}

unittest {
    auto s = initState();
    assert(s.alive);
    assert(!s.ready);

    // Liveness: alive
    auto liveResp = handleRequest(HttpRequest("GET", "/livez"), s);
    assert(liveResp.statusCode == 200);

    // Readiness: not ready yet
    auto readyResp = handleRequest(HttpRequest("GET", "/readyz"), s);
    assert(readyResp.statusCode == 503);

    // Make ready
    s = setReady(s, true);
    auto readyResp2 = handleRequest(HttpRequest("GET", "/readyz"), s);
    assert(readyResp2.statusCode == 200);

    // Health: alive + ready = 200
    s = setUptime(s, 100);
    s = incrementRequests(s);
    s = incrementRequests(s);
    auto healthResp = handleRequest(HttpRequest("GET", "/healthz"), s);
    assert(healthResp.statusCode == 200);
    auto j = parseJSON(healthResp.body_);
    assert(j["alive"].boolean == true);
    assert(j["ready"].boolean == true);
    assert(j["request_count"].integer == 2);

    // Kill it
    s = setAlive(s, false);
    auto deadResp = handleRequest(HttpRequest("GET", "/livez"), s);
    assert(deadResp.statusCode == 503);

    // Health: not alive = 503
    auto unhealthyResp = handleRequest(HttpRequest("GET", "/healthz"), s);
    assert(unhealthyResp.statusCode == 503);

    // 404
    auto notFound = handleRequest(HttpRequest("GET", "/missing"), initState());
    assert(notFound.statusCode == 404);

    // Parse request
    auto req = parseRequest("GET /livez HTTP/1.1\r\nHost: localhost\r\n\r\n");
    assert(req.path == "/livez");

    // Format response
    auto raw = formatResponse(HttpResponse(200, "text/plain", "ok"));
    assert(raw.length > 0);
    import std.string : indexOf;
    assert(raw.indexOf("200 OK") >= 0);
}
