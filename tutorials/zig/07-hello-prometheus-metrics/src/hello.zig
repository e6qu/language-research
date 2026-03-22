const std = @import("std");

pub const Counter = struct {
    name: []const u8,
    help: []const u8,
    value: u64 = 0,

    pub fn inc(self: *Counter) void {
        self.value += 1;
    }

    pub fn add(self: *Counter, n: u64) void {
        self.value += n;
    }

    pub fn format(self: *const Counter, writer: anytype) !void {
        try writer.print("# HELP {s} {s}\n", .{ self.name, self.help });
        try writer.print("# TYPE {s} counter\n", .{self.name});
        try writer.print("{s} {d}\n", .{ self.name, self.value });
    }
};

pub const Gauge = struct {
    name: []const u8,
    help: []const u8,
    value: i64 = 0,

    pub fn set(self: *Gauge, v: i64) void {
        self.value = v;
    }

    pub fn inc(self: *Gauge) void {
        self.value += 1;
    }

    pub fn dec(self: *Gauge) void {
        self.value -= 1;
    }

    pub fn format(self: *const Gauge, writer: anytype) !void {
        try writer.print("# HELP {s} {s}\n", .{ self.name, self.help });
        try writer.print("# TYPE {s} gauge\n", .{self.name});
        try writer.print("{s} {d}\n", .{ self.name, self.value });
    }
};

pub const Registry = struct {
    counters: []Counter,
    gauges: []Gauge,

    pub fn formatAll(self: *const Registry, writer: anytype) !void {
        for (self.counters) |*c| {
            try c.format(writer);
            try writer.writeAll("\n");
        }
        for (self.gauges) |*g| {
            try g.format(writer);
            try writer.writeAll("\n");
        }
    }
};

test "counter inc" {
    var c = Counter{ .name = "http_requests_total", .help = "Total HTTP requests" };
    c.inc();
    c.inc();
    try std.testing.expectEqual(@as(u64, 2), c.value);
}

test "counter add" {
    var c = Counter{ .name = "bytes_total", .help = "Total bytes" };
    c.add(100);
    try std.testing.expectEqual(@as(u64, 100), c.value);
}

test "counter format" {
    var c = Counter{ .name = "http_requests_total", .help = "Total HTTP requests", .value = 42 };
    var buf: [512]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buf);
    try c.format(fbs.writer());
    const output = fbs.getWritten();
    try std.testing.expect(std.mem.indexOf(u8, output, "# HELP http_requests_total Total HTTP requests") != null);
    try std.testing.expect(std.mem.indexOf(u8, output, "# TYPE http_requests_total counter") != null);
    try std.testing.expect(std.mem.indexOf(u8, output, "http_requests_total 42") != null);
}

test "gauge set and dec" {
    var g = Gauge{ .name = "active_connections", .help = "Active connections" };
    g.set(10);
    g.dec();
    try std.testing.expectEqual(@as(i64, 9), g.value);
}

test "gauge format" {
    var g = Gauge{ .name = "active_connections", .help = "Active connections", .value = 5 };
    var buf: [512]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buf);
    try g.format(fbs.writer());
    const output = fbs.getWritten();
    try std.testing.expect(std.mem.indexOf(u8, output, "# TYPE active_connections gauge") != null);
    try std.testing.expect(std.mem.indexOf(u8, output, "active_connections 5") != null);
}

test "registry formatAll" {
    var counters = [_]Counter{
        .{ .name = "req_total", .help = "Requests", .value = 10 },
    };
    var gauges = [_]Gauge{
        .{ .name = "conns", .help = "Connections", .value = 3 },
    };
    const reg = Registry{ .counters = &counters, .gauges = &gauges };
    var buf: [1024]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buf);
    try reg.formatAll(fbs.writer());
    const output = fbs.getWritten();
    try std.testing.expect(std.mem.indexOf(u8, output, "req_total 10") != null);
    try std.testing.expect(std.mem.indexOf(u8, output, "conns 3") != null);
}
