const std = @import("std");

pub const Status = enum {
    up,
    down,

    pub fn toString(self: Status) []const u8 {
        return switch (self) {
            .up => "up",
            .down => "down",
        };
    }
};

pub const DependencyState = struct {
    mutex: std.Thread.Mutex = .{},
    database: Status = .up,
    cache: Status = .up,

    pub fn setDatabase(self: *DependencyState, status: Status) void {
        self.mutex.lock();
        defer self.mutex.unlock();
        self.database = status;
    }

    pub fn setCache(self: *DependencyState, status: Status) void {
        self.mutex.lock();
        defer self.mutex.unlock();
        self.cache = status;
    }

    pub fn isReady(self: *DependencyState) bool {
        self.mutex.lock();
        defer self.mutex.unlock();
        return self.database == .up and self.cache == .up;
    }

    pub fn getDatabase(self: *DependencyState) Status {
        self.mutex.lock();
        defer self.mutex.unlock();
        return self.database;
    }

    pub fn getCache(self: *DependencyState) Status {
        self.mutex.lock();
        defer self.mutex.unlock();
        return self.cache;
    }
};

pub const Route = enum {
    livez,
    readyz,
    healthz,
    not_found,
};

pub fn matchRoute(path: []const u8) Route {
    if (std.mem.eql(u8, path, "/livez")) return .livez;
    if (std.mem.eql(u8, path, "/readyz")) return .readyz;
    if (std.mem.eql(u8, path, "/healthz")) return .healthz;
    return .not_found;
}

pub fn buildLivenessJson(allocator: std.mem.Allocator) ![]u8 {
    return try std.fmt.allocPrint(allocator, "{{\"status\":\"alive\"}}", .{});
}

pub fn buildReadinessJson(allocator: std.mem.Allocator, state: *DependencyState) ![]u8 {
    const ready = state.isReady();
    const status = if (ready) "ready" else "not_ready";
    return try std.fmt.allocPrint(allocator,
        "{{\"status\":\"{s}\",\"database\":\"{s}\",\"cache\":\"{s}\"}}",
        .{ status, state.getDatabase().toString(), state.getCache().toString() },
    );
}

pub fn buildHealthJson(allocator: std.mem.Allocator, state: *DependencyState) ![]u8 {
    const db = state.getDatabase();
    const cache = state.getCache();
    const healthy = (db == .up and cache == .up);
    const status = if (healthy) "healthy" else "degraded";
    return try std.fmt.allocPrint(allocator,
        "{{\"status\":\"{s}\",\"checks\":{{\"database\":\"{s}\",\"cache\":\"{s}\"}}}}",
        .{ status, db.toString(), cache.toString() },
    );
}

test "matchRoute livez" {
    try std.testing.expectEqual(Route.livez, matchRoute("/livez"));
}

test "matchRoute readyz" {
    try std.testing.expectEqual(Route.readyz, matchRoute("/readyz"));
}

test "matchRoute healthz" {
    try std.testing.expectEqual(Route.healthz, matchRoute("/healthz"));
}

test "matchRoute not found" {
    try std.testing.expectEqual(Route.not_found, matchRoute("/other"));
}

test "DependencyState initially ready" {
    var state = DependencyState{};
    try std.testing.expect(state.isReady());
}

test "DependencyState not ready when db down" {
    var state = DependencyState{};
    state.setDatabase(.down);
    try std.testing.expect(!state.isReady());
}

test "DependencyState not ready when cache down" {
    var state = DependencyState{};
    state.setCache(.down);
    try std.testing.expect(!state.isReady());
}

test "buildLivenessJson" {
    const allocator = std.testing.allocator;
    const json = try buildLivenessJson(allocator);
    defer allocator.free(json);
    try std.testing.expectEqualStrings("{\"status\":\"alive\"}", json);
}

test "buildReadinessJson ready" {
    const allocator = std.testing.allocator;
    var state = DependencyState{};
    const json = try buildReadinessJson(allocator, &state);
    defer allocator.free(json);
    try std.testing.expect(std.mem.indexOf(u8, json, "\"ready\"") != null);
}

test "buildReadinessJson not ready" {
    const allocator = std.testing.allocator;
    var state = DependencyState{};
    state.setDatabase(.down);
    const json = try buildReadinessJson(allocator, &state);
    defer allocator.free(json);
    try std.testing.expect(std.mem.indexOf(u8, json, "\"not_ready\"") != null);
}

test "buildHealthJson healthy" {
    const allocator = std.testing.allocator;
    var state = DependencyState{};
    const json = try buildHealthJson(allocator, &state);
    defer allocator.free(json);
    try std.testing.expect(std.mem.indexOf(u8, json, "\"healthy\"") != null);
}

test "buildHealthJson degraded" {
    const allocator = std.testing.allocator;
    var state = DependencyState{};
    state.setCache(.down);
    const json = try buildHealthJson(allocator, &state);
    defer allocator.free(json);
    try std.testing.expect(std.mem.indexOf(u8, json, "\"degraded\"") != null);
}
