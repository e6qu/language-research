const std = @import("std");
const hello = @import("hello.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const all_args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, all_args);

    // Skip program name
    const args = if (all_args.len > 1) all_args[1..] else all_args[0..0];
    const cli = try hello.parseArgs(allocator, args);
    const msg = try hello.formatGreeting(allocator, cli);
    defer allocator.free(msg);

    const stdout = std.fs.File.stdout();
    try stdout.writeAll(msg);
    try stdout.writeAll("\n");
}
