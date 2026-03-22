const std = @import("std");
const hello = @import("hello.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const urls = &[_][]const u8{
        "https://api.example.com/users",
        "https://api.example.com/posts",
        "https://api.example.com/comments",
        "https://api.example.com/todos",
    };

    const stdout = std.io.getStdOut().writer();
    try stdout.print("Fetching {d} URLs concurrently...\n\n", .{urls.len});

    var timer = try std.time.Timer.start();
    const results = try hello.fetchConcurrently(allocator, urls);
    defer allocator.free(results);
    const elapsed_ms = timer.read() / std.time.ns_per_ms;

    for (results) |r| {
        try stdout.print("  thread={d} url={s} latency={d}ms\n", .{ r.thread_id, r.url, r.latency_ms });
    }

    try stdout.print("\nTotal wall time: {d}ms\n", .{elapsed_ms});
}
