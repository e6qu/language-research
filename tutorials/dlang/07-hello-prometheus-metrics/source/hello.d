module hello;

import std.format : format;
import std.array : appender;

struct Counter {
    string name;
    string help;
    string[string] labels;
    double value;
}

struct Gauge {
    string name;
    string help;
    double value;
}

struct MetricsRegistry {
    Counter[] counters;
    Gauge[] gauges;
}

MetricsRegistry newRegistry() {
    MetricsRegistry r;
    return r;
}

MetricsRegistry addCounter(MetricsRegistry r, string name, string help, string[string] labels = null) {
    r.counters ~= Counter(name, help, labels, 0);
    return r;
}

MetricsRegistry addGauge(MetricsRegistry r, string name, string help) {
    r.gauges ~= Gauge(name, help, 0);
    return r;
}

MetricsRegistry incrementCounter(MetricsRegistry r, string name, double amount = 1.0) {
    foreach (ref c; r.counters) {
        if (c.name == name) {
            c.value += amount;
        }
    }
    return r;
}

MetricsRegistry setGauge(MetricsRegistry r, string name, double value) {
    foreach (ref g; r.gauges) {
        if (g.name == name) {
            g.value = value;
        }
    }
    return r;
}

string formatLabels(string[string] labels) {
    if (labels is null || labels.length == 0) return "";
    auto buf = appender!string;
    buf.put("{");
    bool first = true;
    foreach (k, v; labels) {
        if (!first) buf.put(",");
        buf.put(format!`%s="%s"`(k, v));
        first = false;
    }
    buf.put("}");
    return buf.data;
}

string toPrometheus(MetricsRegistry r) {
    auto buf = appender!string;

    foreach (c; r.counters) {
        buf.put(format!"# HELP %s %s\n"(c.name, c.help));
        buf.put(format!"# TYPE %s counter\n"(c.name));
        buf.put(format!"%s%s %g\n"(c.name, formatLabels(c.labels), c.value));
    }

    foreach (g; r.gauges) {
        buf.put(format!"# HELP %s %s\n"(g.name, g.help));
        buf.put(format!"# TYPE %s gauge\n"(g.name));
        buf.put(format!"%s %g\n"(g.name, g.value));
    }

    return buf.data;
}

unittest {
    auto r = newRegistry();
    r = addCounter(r, "http_requests_total", "Total HTTP requests");
    r = addGauge(r, "temperature_celsius", "Current temperature");

    r = incrementCounter(r, "http_requests_total");
    r = incrementCounter(r, "http_requests_total");
    r = incrementCounter(r, "http_requests_total", 3.0);
    r = setGauge(r, "temperature_celsius", 23.5);

    assert(r.counters[0].value == 5.0);
    assert(r.gauges[0].value == 23.5);

    auto output = toPrometheus(r);
    import std.string : indexOf;
    assert(output.indexOf("# HELP http_requests_total") >= 0);
    assert(output.indexOf("# TYPE http_requests_total counter") >= 0);
    assert(output.indexOf("http_requests_total 5") >= 0);
    assert(output.indexOf("temperature_celsius 23.5") >= 0);

    // Labels
    string[string] lbl;
    lbl["method"] = "GET";
    assert(formatLabels(lbl) == `{method="GET"}`);
    assert(formatLabels(null) == "");
}
