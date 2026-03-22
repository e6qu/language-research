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

    const stdout = std.fs.File.stdout();
    const header = try std.fmt.allocPrint(allocator, "Fetching {d} URLs concurrently...\n\n", .{urls.len});
    defer allocator.free(header);
    try stdout.writeAll(header);

    var timer = try std.time.Timer.start();
    const results = try hello.fetchConcurrently(allocator, urls);
    defer allocator.free(results);
    const elapsed_ms = timer.read() / std.time.ns_per_ms;

    for (results) |r| {
        const line = try std.fmt.allocPrint(allocator, "  thread={d} url={s} latency={d}ms\n", .{ r.thread_id, r.url, r.latency_ms });
        defer allocator.free(line);
        try stdout.writeAll(line);
    }

    const footer = try std.fmt.allocPrint(allocator, "\nTotal wall time: {d}ms\n", .{elapsed_ms});
    defer allocator.free(footer);
    try stdout.writeAll(footer);
}
