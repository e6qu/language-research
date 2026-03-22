const std = @import("std");

pub const Info = struct {
    title: []const u8,
    version: []const u8,
    description: []const u8,
};

pub const PathItem = struct {
    summary: []const u8,
    operationId: []const u8,
    responses: Responses,
};

pub const Responses = struct {
    @"200": ResponseObj,
};

pub const ResponseObj = struct {
    description: []const u8,
};

pub const Paths = struct {
    @"/": ?PathGet = null,
    @"/greet/{name}": ?PathGet = null,
};

pub const PathGet = struct {
    get: PathItem,
};

pub const OpenApiSpec = struct {
    openapi: []const u8 = "3.0.3",
    info: Info,
    paths: Paths,
};

pub fn buildSpec() OpenApiSpec {
    return .{
        .info = .{
            .title = "Hello API",
            .version = "1.0.0",
            .description = "A minimal greeting API",
        },
        .paths = .{
            .@"/" = .{
                .get = .{
                    .summary = "Service status",
                    .operationId = "getRoot",
                    .responses = .{ .@"200" = .{ .description = "OK" } },
                },
            },
            .@"/greet/{name}" = .{
                .get = .{
                    .summary = "Greet by name",
                    .operationId = "greetByName",
                    .responses = .{ .@"200" = .{ .description = "Greeting response" } },
                },
            },
        },
    };
}

pub fn serializeSpec(allocator: std.mem.Allocator, spec: OpenApiSpec) ![]u8 {
    return try std.fmt.allocPrint(allocator, "{{\"openapi\":\"{s}\",\"title\":\"{s}\",\"version\":\"{s}\"}}", .{ spec.openapi, spec.info.title, spec.info.version });
}

test "buildSpec has correct openapi version" {
    const spec = buildSpec();
    try std.testing.expectEqualStrings("3.0.3", spec.openapi);
}

test "buildSpec has info" {
    const spec = buildSpec();
    try std.testing.expectEqualStrings("Hello API", spec.info.title);
    try std.testing.expectEqualStrings("1.0.0", spec.info.version);
}

test "buildSpec has paths" {
    const spec = buildSpec();
    try std.testing.expect(spec.paths.@"/" != null);
    try std.testing.expect(spec.paths.@"/greet/{name}" != null);
}

test "serializeSpec produces JSON" {
    const allocator = std.testing.allocator;
    const spec = buildSpec();
    const json = try serializeSpec(allocator, spec);
    defer allocator.free(json);

    try std.testing.expect(json.len > 0);
    try std.testing.expect(std.mem.indexOf(u8, json, "\"openapi\"") != null);
    try std.testing.expect(std.mem.indexOf(u8, json, "\"Hello API\"") != null);
}

test "serializeSpec contains openapi" {
    const allocator = std.testing.allocator;
    const spec = buildSpec();
    const json = try serializeSpec(allocator, spec);
    defer allocator.free(json);
    try std.testing.expect(std.mem.indexOf(u8, json, "3.0.3") != null);
    try std.testing.expect(std.mem.indexOf(u8, json, "Hello API") != null);
}
