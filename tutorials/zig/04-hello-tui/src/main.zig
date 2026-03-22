const std = @import("std");
const hello = @import("hello.zig");

pub fn main() !void {
    const stdin = std.io.getStdIn();
    const stdout = std.io.getStdOut().writer();

    const items = &[_][]const u8{
        "Build something",
        "Test everything",
        "Deploy to prod",
        "Take a break",
    };
    var state = hello.State{ .items = items };

    // Set terminal to raw mode
    var original_termios = try std.posix.tcgetattr(stdin.handle);
    var raw = original_termios;
    raw.lflag = raw.lflag.fromInt(raw.lflag.toInt() & ~@as(u32, @intFromEnum(std.posix.LFLAG.ICANON) | @intFromEnum(std.posix.LFLAG.ECHO)));
    try std.posix.tcsetattr(stdin.handle, .FLUSH, raw);
    defer std.posix.tcsetattr(stdin.handle, .FLUSH, original_termios) catch {};

    // Hide cursor
    try stdout.writeAll("\x1b[?25l");
    defer stdout.writeAll("\x1b[?25h") catch {};

    try hello.render(stdout, &state);

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
        try hello.render(stdout, &state);
    }

    try stdout.writeAll(hello.CLEAR_SCREEN);
    try stdout.print("Selected: {s}\n", .{state.selected()});
}
