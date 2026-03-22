module hello_cli;
import std::io;

fn int main(String[] args) {
    Config config = parse_args(args);
    char[] greeting = format_greeting(config.name, config.shout);
    io::printn(greeting);
    return 0;
}
