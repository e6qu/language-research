module hello;

import std.string : toUpper;

struct CliArgs {
    string name;
    bool shout;
    bool help;
}

CliArgs parseArgs(string[] args) {
    CliArgs result;
    size_t i = 1; // skip program name
    while (i < args.length) {
        if (args[i] == "--name" && i + 1 < args.length) {
            result.name = args[i + 1];
            i += 2;
        } else if (args[i] == "--shout") {
            result.shout = true;
            i++;
        } else if (args[i] == "--help" || args[i] == "-h") {
            result.help = true;
            i++;
        } else {
            i++;
        }
    }
    return result;
}

string formatOutput(CliArgs cli) {
    string msg;
    if (cli.name.length == 0) {
        msg = "Hello, world!";
    } else {
        msg = "Hello, " ~ cli.name ~ "!";
    }
    if (cli.shout) {
        msg = msg.toUpper();
    }
    return msg;
}

unittest {
    auto a1 = parseArgs(["prog", "--name", "Alice"]);
    assert(a1.name == "Alice");
    assert(!a1.shout);

    auto a2 = parseArgs(["prog", "--name", "Bob", "--shout"]);
    assert(a2.name == "Bob");
    assert(a2.shout);

    auto a3 = parseArgs(["prog", "--help"]);
    assert(a3.help);

    auto a4 = parseArgs(["prog"]);
    assert(a4.name == "");

    assert(formatOutput(CliArgs("", false, false)) == "Hello, world!");
    assert(formatOutput(CliArgs("Alice", false, false)) == "Hello, Alice!");
    assert(formatOutput(CliArgs("Alice", true, false)) == "HELLO, ALICE!");
    assert(formatOutput(CliArgs("", true, false)) == "HELLO, WORLD!");
}
