const std = @import("std");
const hello = @import("hello.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const stdout = std.io.getStdOut().writer();
    const logger = hello.Logger.init(allocator, "hello-structured-logging");

    try logger.info(stdout, "Application started");
    try logger.debug(stdout, "Loading configuration");
    try logger.info(stdout, "Server listening on :8080");
    try logger.warn(stdout, "High memory usage detected");
    try logger.err(stdout, "Connection to database lost");
    try logger.info(stdout, "Application shutdown complete");
}
