const std = @import("std");
const hello = @import("hello.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const address = std.net.Address.parseIp("127.0.0.1", 8080) catch unreachable;
    var server = try address.listen(.{ .reuse_address = true });
    defer server.deinit();

    std.log.info("Listening on http://127.0.0.1:8080", .{});

    while (true) {
        var conn = try server.accept();
        defer conn.stream.close();

        // Read request
        var req_buf: [4096]u8 = undefined;
        const n = conn.stream.read(&req_buf) catch continue;
        if (n == 0) continue;

        const request_line = blk: {
            const end = std.mem.indexOf(u8, req_buf[0..n], "\r\n") orelse n;
            break :blk req_buf[0..end];
        };

        // Parse path from "GET /path HTTP/1.1"
        const path = parsePath(request_line);
        handleRequest(allocator, conn.stream, path) catch |err| {
            std.log.err("Request error: {}", .{err});
            continue;
        };
    }
}

fn parsePath(request_line: []const u8) []const u8 {
    // Find first space (after method)
    const start = (std.mem.indexOf(u8, request_line, " ") orelse return "/") + 1;
    const rest = request_line[start..];
    const end = std.mem.indexOf(u8, rest, " ") orelse rest.len;
    return rest[0..end];
}

fn handleRequest(allocator: std.mem.Allocator, stream: std.net.Stream, path: []const u8) !void {
    const route = hello.matchRoute(path);

    switch (route) {
        .root => {
            const body = try hello.buildRootJson(allocator);
            defer allocator.free(body);
            try sendResponse(allocator, stream, "200 OK", body);
        },
        .greet => {
            const name = hello.extractName(path);
            const body = try hello.buildJsonGreeting(allocator, name);
            defer allocator.free(body);
            try sendResponse(allocator, stream, "200 OK", body);
        },
        .not_found => {
            try sendResponse(allocator, stream, "404 Not Found", "{\"error\":\"not found\"}");
        },
    }
}

fn sendResponse(allocator: std.mem.Allocator, stream: std.net.Stream, status: []const u8, body: []const u8) !void {
    const header = try std.fmt.allocPrint(allocator, "HTTP/1.1 {s}\r\nContent-Type: application/json\r\nContent-Length: {d}\r\nConnection: close\r\n\r\n", .{ status, body.len });
    defer allocator.free(header);
    try stream.writeAll(header);
    try stream.writeAll(body);
}
