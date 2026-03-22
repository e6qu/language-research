const std = @import("std");

pub const CliArgs = struct {
    name: []const u8 = "",
    shout: bool = false,
};

pub fn parseArgs(allocator: std.mem.Allocator, args: []const []const u8) !CliArgs {
    _ = allocator;
    var result = CliArgs{};
    var i: usize = 0;
    while (i < args.len) : (i += 1) {
        if (std.mem.eql(u8, args[i], "--name") and i + 1 < args.len) {
            i += 1;
            result.name = args[i];
        } else if (std.mem.eql(u8, args[i], "--shout")) {
            result.shout = true;
        }
    }
    return result;
}

pub fn formatGreeting(allocator: std.mem.Allocator, cli: CliArgs) ![]u8 {
    const name = if (cli.name.len > 0) cli.name else "world";
    const msg = try std.fmt.allocPrint(allocator, "Hello, {s}!", .{name});

    if (cli.shout) {
        for (msg) |*c| {
            c.* = std.ascii.toUpper(c.*);
        }
    }
    return msg;
}

test "parseArgs defaults" {
    const args = &[_][]const u8{};
    const cli = try parseArgs(std.testing.allocator, args);
    try std.testing.expectEqualStrings("", cli.name);
    try std.testing.expect(!cli.shout);
}

test "parseArgs with name" {
    const args = &[_][]const u8{ "--name", "Zig" };
    const cli = try parseArgs(std.testing.allocator, args);
    try std.testing.expectEqualStrings("Zig", cli.name);
}

test "parseArgs with shout" {
    const args = &[_][]const u8{ "--name", "Zig", "--shout" };
    const cli = try parseArgs(std.testing.allocator, args);
    try std.testing.expectEqualStrings("Zig", cli.name);
    try std.testing.expect(cli.shout);
}

test "formatGreeting default" {
    const allocator = std.testing.allocator;
    const msg = try formatGreeting(allocator, .{});
    defer allocator.free(msg);
    try std.testing.expectEqualStrings("Hello, world!", msg);
}

test "formatGreeting named" {
    const allocator = std.testing.allocator;
    const msg = try formatGreeting(allocator, .{ .name = "Zig" });
    defer allocator.free(msg);
    try std.testing.expectEqualStrings("Hello, Zig!", msg);
}

test "formatGreeting shout" {
    const allocator = std.testing.allocator;
    const msg = try formatGreeting(allocator, .{ .name = "Zig", .shout = true });
    defer allocator.free(msg);
    try std.testing.expectEqualStrings("HELLO, ZIG!", msg);
}
