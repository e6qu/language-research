const std = @import("std");
const hello = @import("hello.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const stdin = std.fs.File.stdin();
    const stdout = std.fs.File.stdout();

    const items = &[_][]const u8{
        "Build something",
        "Test everything",
        "Deploy to prod",
        "Take a break",
    };
    var state = hello.State{ .items = items };

    // Set terminal to raw mode
    const original_termios = try std.posix.tcgetattr(stdin.handle);
    var raw = original_termios;
    raw.lflag.ICANON = false;
    raw.lflag.ECHO = false;
    try std.posix.tcsetattr(stdin.handle, .FLUSH, raw);
    defer std.posix.tcsetattr(stdin.handle, .FLUSH, original_termios) catch {};

    // Hide cursor
    try stdout.writeAll("\x1b[?25l");
    defer stdout.writeAll("\x1b[?25h") catch {};

    try renderToFile(allocator, stdout, &state);

    while (true) {
        var buf: [1]u8 = undefined;
        const n = try stdin.read(&buf);
        if (n == 0) break;

        switch (buf[0]) {
            'q' => break,
            'k' => state.moveUp(),
            'j' => state.moveDown(),
            else => continue,
        }
        try renderToFile(allocator, stdout, &state);
    }

    try stdout.writeAll(hello.CLEAR_SCREEN);
    const selected_msg = try std.fmt.allocPrint(allocator, "Selected: {s}\n", .{state.selected()});
    defer allocator.free(selected_msg);
    try stdout.writeAll(selected_msg);
}

fn renderToFile(allocator: std.mem.Allocator, stdout: std.fs.File, state: *const hello.State) !void {
    _ = allocator;
    var buf: [4096]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buf);
    try hello.render(fbs.writer(), state);
    try stdout.writeAll(fbs.getWritten());
}
