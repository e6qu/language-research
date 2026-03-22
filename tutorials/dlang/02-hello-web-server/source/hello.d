module hello;

import std.string : indexOf, strip, startsWith;
import std.conv : to;
import std.array : split;

struct HttpRequest {
    string method;
    string path;
    string httpVersion;
}

struct HttpResponse {
    int statusCode;
    string statusText;
    string contentType;
    string body;

    string toRaw() {
        import std.format : format;
        return format!"HTTP/1.1 %d %s\r\nContent-Type: %s\r\nContent-Length: %d\r\nConnection: close\r\n\r\n%s"(
            statusCode, statusText, contentType, body.length, body);
    }
}

HttpRequest parseRequest(string raw) {
    auto lines = raw.split("\r\n");
    if (lines.length == 0) {
        return HttpRequest("", "", "");
    }
    auto parts = lines[0].split(" ");
    if (parts.length < 3) {
        return HttpRequest("", "", "");
    }
    return HttpRequest(parts[0], parts[1], parts[2]);
}

HttpResponse handleRequest(HttpRequest req) {
    if (req.path == "/") {
        return HttpResponse(200, "OK", "text/plain", "Hello, world!");
    }
    if (req.path.startsWith("/greet/")) {
        auto name = req.path["/greet/".length .. $];
        return HttpResponse(200, "OK", "text/plain", "Hello, " ~ name ~ "!");
    }
    if (req.path == "/health") {
        return HttpResponse(200, "OK", "application/json", `{"status":"ok"}`);
    }
    return HttpResponse(404, "Not Found", "text/plain", "Not Found");
}

unittest {
    auto req = parseRequest("GET / HTTP/1.1\r\nHost: localhost\r\n\r\n");
    assert(req.method == "GET");
    assert(req.path == "/");

    auto resp = handleRequest(req);
    assert(resp.statusCode == 200);
    assert(resp.body == "Hello, world!");

    auto notFound = handleRequest(HttpRequest("GET", "/missing", "HTTP/1.1"));
    assert(notFound.statusCode == 404);

    auto health = handleRequest(HttpRequest("GET", "/health", "HTTP/1.1"));
    assert(health.statusCode == 200);
    assert(health.body == `{"status":"ok"}`);

    auto raw = resp.toRaw();
    assert(raw.length > 0);
    import std.string : startsWith;
    assert(raw.startsWith("HTTP/1.1 200 OK"));
}
