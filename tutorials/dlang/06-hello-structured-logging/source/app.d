import hello;
import std.stdio;

void main() {
    auto e1 = makeEntry(LogLevel.INFO, "Application started", "main");
    writeln(toJson(e1));

    string[string] extras;
    extras["port"] = "8080";
    auto e2 = makeEntry(LogLevel.INFO, "Listening", "server", extras);
    writeln(toJson(e2));

    auto e3 = makeEntry(LogLevel.WARN, "High memory usage", "monitor");
    writeln(toJson(e3));

    string[string] errExtras;
    errExtras["error"] = "connection refused";
    errExtras["retry"] = "3";
    auto e4 = makeEntry(LogLevel.ERROR, "Database connection failed", "db", errExtras);
    writeln(toJson(e4));
}
