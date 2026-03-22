const std = @import("std");

pub const FetchResult = struct {
    url: []const u8,
    latency_ms: u64,
    thread_id: usize,
};

pub fn simulateFetch(url: []const u8, id: usize) FetchResult {
    // Simulate network latency based on URL length
    const delay_ns: u64 = @as(u64, url.len) * 10 * std.time.ns_per_ms;
    std.time.sleep(delay_ns);

    return FetchResult{
        .url = url,
        .latency_ms = url.len * 10,
        .thread_id = id,
    };
}

pub fn fetchConcurrently(
    allocator: std.mem.Allocator,
    urls: []const []const u8,
) ![]FetchResult {
    const results = try allocator.alloc(FetchResult, urls.len);
    errdefer allocator.free(results);

    var threads = try allocator.alloc(std.Thread, urls.len);
    defer allocator.free(threads);

    for (urls, 0..) |url, i| {
        threads[i] = try std.Thread.spawn(.{}, struct {
            fn run(u: []const u8, idx: usize, res: *FetchResult) void {
                res.* = simulateFetch(u, idx);
            }
        }.run, .{ url, i, &results[i] });
    }

    for (threads) |t| {
        t.join();
    }

    return results;
}

test "simulateFetch returns result" {
    const result = simulateFetch("https://example.com", 0);
    try std.testing.expectEqualStrings("https://example.com", result.url);
    try std.testing.expectEqual(@as(usize, 0), result.thread_id);
    try std.testing.expect(result.latency_ms > 0);
}

test "fetchConcurrently all urls" {
    const allocator = std.testing.allocator;
    const urls = &[_][]const u8{
        "https://a.com",
        "https://b.com",
        "https://c.com",
    };
    const results = try fetchConcurrently(allocator, urls);
    defer allocator.free(results);

    try std.testing.expectEqual(@as(usize, 3), results.len);
    for (results, 0..) |r, i| {
        try std.testing.expectEqual(i, r.thread_id);
    }
}

test "fetchConcurrently empty" {
    const allocator = std.testing.allocator;
    const urls = &[_][]const u8{};
    const results = try fetchConcurrently(allocator, urls);
    defer allocator.free(results);
    try std.testing.expectEqual(@as(usize, 0), results.len);
}
