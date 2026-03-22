const std = @import("std");

pub const Route = enum {
    root,
    greet,
    not_found,
};

pub fn matchRoute(path: []const u8) Route {
    if (std.mem.eql(u8, path, "/")) return .root;
    if (std.mem.startsWith(u8, path, "/greet/")) return .greet;
    return .not_found;
}

pub fn extractName(path: []const u8) []const u8 {
    const prefix = "/greet/";
    if (std.mem.startsWith(u8, path, prefix)) {
        return path[prefix.len..];
    }
    return "";
}

pub fn buildJsonGreeting(allocator: std.mem.Allocator, name: []const u8) ![]u8 {
    if (name.len == 0) {
        return try std.fmt.allocPrint(allocator, "{{\"message\":\"Hello, world!\"}}", .{});
    }
    return try std.fmt.allocPrint(allocator, "{{\"message\":\"Hello, {s}!\"}}", .{name});
}

pub fn buildRootJson(allocator: std.mem.Allocator) ![]u8 {
    return try std.fmt.allocPrint(allocator, "{{\"message\":\"Hello, world!\"}}", .{});
}

test "matchRoute root" {
    try std.testing.expectEqual(Route.root, matchRoute("/"));
}

test "matchRoute greet" {
    try std.testing.expectEqual(Route.greet, matchRoute("/greet/Zig"));
}

test "matchRoute not found" {
    try std.testing.expectEqual(Route.not_found, matchRoute("/unknown"));
}

test "extractName" {
    try std.testing.expectEqualStrings("Zig", extractName("/greet/Zig"));
}

test "extractName empty" {
    try std.testing.expectEqualStrings("", extractName("/other"));
}

test "buildJsonGreeting with name" {
    const allocator = std.testing.allocator;
    const json = try buildJsonGreeting(allocator, "Zig");
    defer allocator.free(json);
    try std.testing.expectEqualStrings("{\"message\":\"Hello, Zig!\"}", json);
}

test "buildJsonGreeting empty" {
    const allocator = std.testing.allocator;
    const json = try buildJsonGreeting(allocator, "");
    defer allocator.free(json);
    try std.testing.expectEqualStrings("{\"message\":\"Hello, world!\"}", json);
}

test "buildRootJson" {
    const allocator = std.testing.allocator;
    const json = try buildRootJson(allocator);
    defer allocator.free(json);
    try std.testing.expectEqualStrings("{\"message\":\"Hello, world!\"}", json);
}
