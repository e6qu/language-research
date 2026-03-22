import hello;
import std.socket;
import std.stdio;

void main() {
    enum ushort PORT = 4120;
    auto server = new TcpSocket();
    server.setOption(SocketOptionLevel.SOCKET, SocketOption.REUSEADDR, true);
    server.bind(new InternetAddress("0.0.0.0", PORT));
    server.listen(10);
    writefln("Listening on http://0.0.0.0:%d", PORT);

    while (true) {
        auto client = server.accept();
        scope(exit) client.close();

        char[4096] buf;
        auto received = client.receive(buf[]);
        if (received <= 0) continue;

        auto raw = cast(string) buf[0 .. received];
        auto req = parseRequest(raw);
        auto resp = handleRequest(req);
        client.send(cast(const(ubyte)[]) resp.toRaw());
    }
}
