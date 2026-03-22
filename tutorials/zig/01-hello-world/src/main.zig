const std = @import("std");
const hello = @import("hello.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const name: []const u8 = if (args.len > 1) args[1] else "";
    const msg = try hello.greetAlloc(allocator, name);
    defer allocator.free(msg);

    const stdout = std.io.getStdOut().writer();
    try stdout.print("{s}\n", .{msg});
}
