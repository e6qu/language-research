const std = @import("std");

pub fn greet(name: []const u8) []const u8 {
    if (name.len == 0) {
        return "Hello, world!";
    }
    return name;
}

/// Returns a formatted greeting string. Caller owns returned memory.
pub fn greetAlloc(allocator: std.mem.Allocator, name: []const u8) ![]u8 {
    if (name.len == 0) {
        return try allocator.dupe(u8, "Hello, world!");
    }
    return try std.fmt.allocPrint(allocator, "Hello, {s}!", .{name});
}

test "greet default" {
    const result = greet("");
    try std.testing.expectEqualStrings("Hello, world!", result);
}

test "greet named" {
    const allocator = std.testing.allocator;
    const result = try greetAlloc(allocator, "Zig");
    defer allocator.free(result);
    try std.testing.expectEqualStrings("Hello, Zig!", result);
}

test "greet empty" {
    const allocator = std.testing.allocator;
    const result = try greetAlloc(allocator, "");
    defer allocator.free(result);
    try std.testing.expectEqualStrings("Hello, world!", result);
}
