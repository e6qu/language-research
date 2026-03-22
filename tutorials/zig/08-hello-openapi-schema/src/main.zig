const std = @import("std");
const hello = @import("hello.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const spec = hello.buildSpec();
    const json = try hello.serializeSpec(allocator, spec);
    defer allocator.free(json);

    const stdout = std.fs.File.stdout();
    try stdout.writeAll(, .{json});
}
