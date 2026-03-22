module hello_web;
import std::io;
import std::net;

// C3 does not have a built-in HTTP framework yet.
// This tutorial demonstrates a minimal TCP listener that
// responds with a hard-coded HTTP response — the simplest
// possible "web server" using only the standard library.

const char[] HTTP_RESPONSE =
    "HTTP/1.1 200 OK\r\n"
    "Content-Type: text/plain\r\n"
    "Content-Length: 13\r\n"
    "\r\n"
    "Hello, world!";

const char[] HTTP_JSON =
    "HTTP/1.1 200 OK\r\n"
    "Content-Type: application/json\r\n"
    "Content-Length: 25\r\n"
    "\r\n"
    "{\"message\":\"Hello, C3!\"}";

fn char[] make_response(bool json) {
    return json ? HTTP_JSON : HTTP_RESPONSE;
}
