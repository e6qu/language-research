const std = @import("std");

pub const Level = enum {
    info,
    warn,
    @"error",
    debug,

    pub fn toString(self: Level) []const u8 {
        return switch (self) {
            .info => "info",
            .warn => "warn",
            .@"error" => "error",
            .debug => "debug",
        };
    }
};

pub const LogEntry = struct {
    level: []const u8,
    message: []const u8,
    service: []const u8,
    timestamp: []const u8,
};

pub fn buildLogJson(allocator: std.mem.Allocator, level: Level, message: []const u8, service: []const u8) ![]u8 {
    const entry = LogEntry{
        .level = level.toString(),
        .message = message,
        .service = service,
        .timestamp = "2026-03-22T00:00:00Z",
    };

    const level_str = switch (level) {
        .debug => "debug",
        .info => "info",
        .warn => "warn",
        .@"error" => "error",
    };
    return try std.fmt.allocPrint(
        allocator,
        "{{\"level\":\"{s}\",\"message\":\"{s}\",\"service\":\"{s}\",\"timestamp\":\"{s}\"}}",
        .{ level_str, message, service, entry.timestamp },
    );
}

pub fn writeLog(writer: anytype, allocator: std.mem.Allocator, level: Level, message: []const u8, service: []const u8) !void {
    const json = try buildLogJson(allocator, level, message, service);
    defer allocator.free(json);
    try writer.print("{s}\n", .{json});
}

pub const Logger = struct {
    allocator: std.mem.Allocator,
    service: []const u8,

    pub fn init(allocator: std.mem.Allocator, service: []const u8) Logger {
        return .{ .allocator = allocator, .service = service };
    }

    pub fn info(self: *const Logger, writer: anytype, message: []const u8) !void {
        try writeLog(writer, self.allocator, .info, message, self.service);
    }

    pub fn warn(self: *const Logger, writer: anytype, message: []const u8) !void {
        try writeLog(writer, self.allocator, .warn, message, self.service);
    }

    pub fn err(self: *const Logger, writer: anytype, message: []const u8) !void {
        try writeLog(writer, self.allocator, .@"error", message, self.service);
    }

    pub fn debug(self: *const Logger, writer: anytype, message: []const u8) !void {
        try writeLog(writer, self.allocator, .debug, message, self.service);
    }
};

test "buildLogJson info" {
    const allocator = std.testing.allocator;
    const json = try buildLogJson(allocator, .info, "started", "my-app");
    defer allocator.free(json);

    const parsed = try std.json.parseFromSlice(LogEntry, allocator, json, .{});
    defer parsed.deinit();
    try std.testing.expectEqualStrings("info", parsed.value.level);
    try std.testing.expectEqualStrings("started", parsed.value.message);
    try std.testing.expectEqualStrings("my-app", parsed.value.service);
}

test "buildLogJson error" {
    const allocator = std.testing.allocator;
    const json = try buildLogJson(allocator, .@"error", "failed", "svc");
    defer allocator.free(json);

    const parsed = try std.json.parseFromSlice(LogEntry, allocator, json, .{});
    defer parsed.deinit();
    try std.testing.expectEqualStrings("error", parsed.value.level);
}

test "Logger writes json" {
    const allocator = std.testing.allocator;
    const logger = Logger.init(allocator, "test-svc");
    var buf: [1024]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buf);
    try logger.info(fbs.writer(), "hello");
    const output = fbs.getWritten();
    try std.testing.expect(std.mem.indexOf(u8, output, "\"level\":\"info\"") != null);
    try std.testing.expect(std.mem.indexOf(u8, output, "\"message\":\"hello\"") != null);
}

test "Level toString" {
    try std.testing.expectEqualStrings("info", Level.info.toString());
    try std.testing.expectEqualStrings("warn", Level.warn.toString());
    try std.testing.expectEqualStrings("error", Level.@"error".toString());
    try std.testing.expectEqualStrings("debug", Level.debug.toString());
}
