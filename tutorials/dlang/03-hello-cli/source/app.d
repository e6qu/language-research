import hello;
import std.stdio;

void main(string[] args) {
    auto cli = parseArgs(args);

    if (cli.help) {
        writeln("Usage: hello-cli [OPTIONS]");
        writeln("  --name NAME   Name to greet");
        writeln("  --shout       Uppercase output");
        writeln("  --help, -h    Show this help");
        return;
    }

    writeln(formatOutput(cli));
}
