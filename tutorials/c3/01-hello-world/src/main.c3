module hello;
import std::io;

fn int main(String[] args) {
    if (args.len > 1) {
        greet(args[1]);
    } else {
        greet("");
    }
    return 0;
}
