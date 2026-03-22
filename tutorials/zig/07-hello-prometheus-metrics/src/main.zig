const std = @import("std");
const hello = @import("hello.zig");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    var counters = [_]hello.Counter{
        .{ .name = "http_requests_total", .help = "Total number of HTTP requests" },
        .{ .name = "http_errors_total", .help = "Total number of HTTP errors" },
    };
    var gauges = [_]hello.Gauge{
        .{ .name = "active_connections", .help = "Number of active connections" },
        .{ .name = "queue_depth", .help = "Current queue depth" },
    };

    // Simulate some activity
    counters[0].add(1547);
    counters[1].add(23);
    gauges[0].set(42);
    gauges[1].set(7);

    const registry = hello.Registry{ .counters = &counters, .gauges = &gauges };
    try registry.formatAll(stdout);
}
