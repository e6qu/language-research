module hello;
import std::io;

fn void greet(char[] name) {
    if (name.len == 0) {
        io::printn("Hello, world!");
    } else {
        io::printfn("Hello, %s!", name);
    }
}
