module hello_cli;
import std::io;

struct Config {
    char[] name;
    bool shout;
}

fn char[] format_greeting(char[] name, bool shout) {
    // Build greeting string
    DString msg;
    if (name.len == 0) {
        msg = dstring::new("Hello, World!");
    } else {
        msg = dstring::temp_new();
        msg.appendf("Hello, %s!", name);
    }
    char[] result = msg.str_view();
    if (shout) {
        return result.to_upper();
    }
    return result;
}

fn Config parse_args(String[] args) {
    Config config = { .name = "World", .shout = false };
    for (usz i = 1; i < args.len; i++) {
        if (args[i] == "--shout" || args[i] == "-s") {
            config.shout = true;
        } else if (args[i] == "--name" || args[i] == "-n") {
            if (i + 1 < args.len) {
                config.name = args[i + 1];
                i++;
            }
        } else {
            config.name = args[i];
        }
    }
    return config;
}
