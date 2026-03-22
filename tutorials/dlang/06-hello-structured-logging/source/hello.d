module hello;

import std.json;
import std.datetime;
import std.conv : to;

enum LogLevel {
    DEBUG,
    INFO,
    WARN,
    ERROR,
}

string logLevelString(LogLevel level) {
    final switch (level) {
        case LogLevel.DEBUG: return "DEBUG";
        case LogLevel.INFO:  return "INFO";
        case LogLevel.WARN:  return "WARN";
        case LogLevel.ERROR: return "ERROR";
    }
}

struct LogEntry {
    LogLevel level;
    string message;
    string component;
    string[string] extra;
    string timestamp; // ISO 8601
}

LogEntry makeEntry(LogLevel level, string message, string component, string[string] extra = null) {
    auto now = Clock.currTime(UTC());
    auto ts = now.toISOExtString();
    return LogEntry(level, message, component, extra, ts);
}

string toJson(LogEntry entry) {
    JSONValue j = JSONValue.emptyObject;
    j["level"] = logLevelString(entry.level);
    j["message"] = entry.message;
    j["component"] = entry.component;
    j["timestamp"] = entry.timestamp;

    if (entry.extra !is null && entry.extra.length > 0) {
        JSONValue extras = JSONValue.emptyObject;
        foreach (k, v; entry.extra) {
            extras[k] = v;
        }
        j["extra"] = extras;
    }

    return j.toString();
}

LogEntry fromJson(string raw) {
    auto j = parseJSON(raw);
    LogEntry entry;
    entry.message = j["message"].str;
    entry.component = j["component"].str;
    entry.timestamp = j["timestamp"].str;

    string lvl = j["level"].str;
    switch (lvl) {
        case "DEBUG": entry.level = LogLevel.DEBUG; break;
        case "INFO":  entry.level = LogLevel.INFO; break;
        case "WARN":  entry.level = LogLevel.WARN; break;
        case "ERROR": entry.level = LogLevel.ERROR; break;
        default: entry.level = LogLevel.INFO;
    }

    if ("extra" in j) {
        foreach (k, v; j["extra"].object) {
            entry.extra[k] = v.str;
        }
    }

    return entry;
}

unittest {
    auto entry = makeEntry(LogLevel.INFO, "Server started", "main");
    assert(entry.level == LogLevel.INFO);
    assert(entry.message == "Server started");
    assert(entry.timestamp.length > 0);

    auto json = toJson(entry);
    auto parsed = parseJSON(json);
    assert(parsed["level"].str == "INFO");
    assert(parsed["message"].str == "Server started");
    assert(parsed["component"].str == "main");

    // Round-trip
    auto decoded = fromJson(json);
    assert(decoded.message == "Server started");
    assert(decoded.level == LogLevel.INFO);

    // With extras
    string[string] extras;
    extras["port"] = "8080";
    extras["host"] = "localhost";
    auto entry2 = makeEntry(LogLevel.DEBUG, "Binding", "server", extras);
    auto json2 = toJson(entry2);
    auto parsed2 = parseJSON(json2);
    assert(parsed2["extra"]["port"].str == "8080");

    assert(logLevelString(LogLevel.ERROR) == "ERROR");
    assert(logLevelString(LogLevel.WARN) == "WARN");
}
