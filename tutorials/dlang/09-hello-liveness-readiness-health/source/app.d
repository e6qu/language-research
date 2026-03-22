import hello;
import std.socket;
import std.stdio;
import std.datetime.stopwatch : StopWatch;

void main() {
    enum ushort PORT = 4123;
    auto server = new TcpSocket();
    server.setOption(SocketOptionLevel.SOCKET, SocketOption.REUSEADDR, true);
    server.bind(new InternetAddress("0.0.0.0", PORT));
    server.listen(10);

    auto state = initState();
    // Mark ready after startup
    state = setReady(state, true);

    StopWatch sw;
    sw.start();

    writefln("Listening on http://0.0.0.0:%d", PORT);
    writeln("Endpoints: /livez /readyz /healthz /");

    while (true) {
        auto client = server.accept();
        scope(exit) client.close();

        char[4096] buf;
        auto received = client.receive(buf[]);
        if (received <= 0) continue;

        auto raw = cast(string) buf[0 .. received];
        auto req = parseRequest(raw);

        state = incrementRequests(state);
        state = setUptime(state, sw.peek.total!"seconds");

        auto resp = handleRequest(req, state);
        client.send(cast(const(ubyte)[]) formatResponse(resp));

        writefln("%s %s -> %d", req.method, req.path, resp.statusCode);
    }
}
