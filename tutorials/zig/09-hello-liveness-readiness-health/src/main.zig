const std = @import("std");
const hello = @import("hello.zig");

var dep_state = hello.DependencyState{};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const address = std.net.Address.parseIp("127.0.0.1", 8080) catch unreachable;
    var server = try address.listen(.{ .reuse_address = true });
    defer server.deinit();

    std.log.info("Health server listening on http://127.0.0.1:8080", .{});
    std.log.info("Endpoints: /livez, /readyz, /healthz", .{});

    while (true) {
        var conn = try server.accept();
        defer conn.stream.close();

        var buf: [4096]u8 = undefined;
        var http_server = std.http.Server.init(conn, &buf);

        var req = http_server.receiveHead() catch continue;
        handleRequest(allocator, &req) catch |err| {
            std.log.err("Request error: {}", .{err});
            continue;
        };
    }
}

fn handleRequest(allocator: std.mem.Allocator, req: *std.http.Server.Request) !void {
    const path = req.head.target;
    const route = hello.matchRoute(path);

    switch (route) {
        .livez => {
            const body = try hello.buildLivenessJson(allocator);
            defer allocator.free(body);
            try req.respond(body, .{
                .extra_headers = &.{.{ .name = "content-type", .value = "application/json" }},
            });
        },
        .readyz => {
            const body = try hello.buildReadinessJson(allocator, &dep_state);
            defer allocator.free(body);
            const status: std.http.Status = if (dep_state.isReady()) .ok else .service_unavailable;
            try req.respond(body, .{
                .status = status,
                .extra_headers = &.{.{ .name = "content-type", .value = "application/json" }},
            });
        },
        .healthz => {
            const body = try hello.buildHealthJson(allocator, &dep_state);
            defer allocator.free(body);
            try req.respond(body, .{
                .extra_headers = &.{.{ .name = "content-type", .value = "application/json" }},
            });
        },
        .not_found => {
            try req.respond("{\"error\":\"not found\"}", .{
                .status = .not_found,
                .extra_headers = &.{.{ .name = "content-type", .value = "application/json" }},
            });
        },
    }
}
