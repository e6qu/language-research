module hello_metrics;
import std::io;

// Minimal in-process metrics registry that renders Prometheus exposition format.

struct Counter {
    char[] name;
    char[] help;
    long   value;
}

struct Gauge {
    char[] name;
    char[] help;
    double value;
}

struct Registry {
    Counter[16] counters;
    usz         counter_count;
    Gauge[16]   gauges;
    usz         gauge_count;
}

fn void Registry.add_counter(Registry* self, char[] name, char[] help) {
    if (self.counter_count >= 16) return;
    self.counters[self.counter_count] = { .name = name, .help = help, .value = 0 };
    self.counter_count++;
}

fn void Registry.inc(Registry* self, char[] name) {
    for (usz i = 0; i < self.counter_count; i++) {
        if (self.counters[i].name == name) {
            self.counters[i].value++;
            return;
        }
    }
}

fn void Registry.add_gauge(Registry* self, char[] name, char[] help, double val) {
    if (self.gauge_count >= 16) return;
    self.gauges[self.gauge_count] = { .name = name, .help = help, .value = val };
    self.gauge_count++;
}

fn void Registry.set_gauge(Registry* self, char[] name, double val) {
    for (usz i = 0; i < self.gauge_count; i++) {
        if (self.gauges[i].name == name) {
            self.gauges[i].value = val;
            return;
        }
    }
}

// Render all metrics in Prometheus text exposition format.
fn void Registry.render(Registry* self) {
    for (usz i = 0; i < self.counter_count; i++) {
        Counter* c = &self.counters[i];
        io::printfn("# HELP %s %s", c.name, c.help);
        io::printfn("# TYPE %s counter", c.name);
        io::printfn("%s %d", c.name, c.value);
    }
    for (usz i = 0; i < self.gauge_count; i++) {
        Gauge* g = &self.gauges[i];
        io::printfn("# HELP %s %s", g.name, g.help);
        io::printfn("# TYPE %s gauge", g.name);
        io::printfn("%s %.2f", g.name, g.value);
    }
}
