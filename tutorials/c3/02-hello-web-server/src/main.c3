module hello_web;
import std::io;
import std::net;

fn int main(String[] args) {
    io::printn("Starting HTTP server on :3000 ...");

    // Open a TCP socket, bind, listen, accept loop.
    // C3's std::net mirrors POSIX sockets.
    TcpServerSocket! server = net::tcp_listen(3000);
    if (catch err = server) {
        io::printfn("Failed to bind: %s", err);
        return 1;
    }

    io::printn("Listening on http://0.0.0.0:3000");

    while (true) {
        TcpSocket! client = server.accept();
        if (catch err = client) {
            io::printfn("Accept error: %s", err);
            continue;
        }
        char[] response = make_response(false);
        client.write(response);
        client.close();
    }
    return 0;
}
