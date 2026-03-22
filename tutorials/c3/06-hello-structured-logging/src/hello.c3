module hello_logging;
import std::io;
import std::time;

enum LogLevel : char {
    DEBUG = 'D',
    INFO  = 'I',
    WARN  = 'W',
    ERROR = 'E',
}

fn char[] level_string(LogLevel level) {
    switch (level) {
        case DEBUG: return "DEBUG";
        case INFO:  return "INFO";
        case WARN:  return "WARN";
        case ERROR: return "ERROR";
    }
}

// Emit a structured JSON log line to stdout.
fn void log_json(LogLevel level, char[] msg, char[] component) {
    // Approximate ISO timestamp via epoch — C3's time API is minimal.
    long ts = time::now().to_unix();
    io::printfn(
        "{\"timestamp\":%d,\"level\":\"%s\",\"component\":\"%s\",\"msg\":\"%s\"}",
        ts, level_string(level), component, msg
    );
}

fn void log_info(char[] msg, char[] component)  { log_json(INFO, msg, component); }
fn void log_warn(char[] msg, char[] component)  { log_json(WARN, msg, component); }
fn void log_error(char[] msg, char[] component) { log_json(ERROR, msg, component); }
fn void log_debug(char[] msg, char[] component) { log_json(DEBUG, msg, component); }
