const std = @import("std");

pub const State = struct {
    items: []const []const u8,
    cursor: usize = 0,

    pub fn moveUp(self: *State) void {
        if (self.cursor > 0) self.cursor -= 1;
    }

    pub fn moveDown(self: *State) void {
        if (self.cursor + 1 < self.items.len) self.cursor += 1;
    }

    pub fn selected(self: *const State) []const u8 {
        return self.items[self.cursor];
    }
};

pub const CLEAR_SCREEN = "\x1b[2J\x1b[H";
pub const BOLD = "\x1b[1m";
pub const RESET = "\x1b[0m";
pub const CYAN = "\x1b[36m";
pub const REVERSE = "\x1b[7m";

pub fn render(writer: anytype, state: *const State) !void {
    try writer.writeAll(CLEAR_SCREEN);
    try writer.print("{s}{s}Hello TUI - Use j/k to navigate, q to quit{s}\n\n", .{ BOLD, CYAN, RESET });

    for (state.items, 0..) |item, i| {
        if (i == state.cursor) {
            try writer.print("  {s}> {s}{s}\n", .{ REVERSE, item, RESET });
        } else {
            try writer.print("    {s}\n", .{item});
        }
    }

    try writer.print("\n  Selected: {s}{s}{s}\n", .{ BOLD, state.selected(), RESET });
}

test "state initial cursor" {
    const items = &[_][]const u8{ "one", "two", "three" };
    const state = State{ .items = items };
    try std.testing.expectEqual(@as(usize, 0), state.cursor);
    try std.testing.expectEqualStrings("one", state.selected());
}

test "state moveDown" {
    const items = &[_][]const u8{ "one", "two", "three" };
    var state = State{ .items = items };
    state.moveDown();
    try std.testing.expectEqual(@as(usize, 1), state.cursor);
    try std.testing.expectEqualStrings("two", state.selected());
}

test "state moveUp at top" {
    const items = &[_][]const u8{ "one", "two" };
    var state = State{ .items = items };
    state.moveUp();
    try std.testing.expectEqual(@as(usize, 0), state.cursor);
}

test "state moveDown at bottom" {
    const items = &[_][]const u8{ "one", "two" };
    var state = State{ .items = items, .cursor = 1 };
    state.moveDown();
    try std.testing.expectEqual(@as(usize, 1), state.cursor);
}

test "render produces output" {
    const items = &[_][]const u8{ "alpha", "beta" };
    const state = State{ .items = items };
    var buf: [1024]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buf);
    try render(fbs.writer(), &state);
    const output = fbs.getWritten();
    try std.testing.expect(output.len > 0);
    try std.testing.expect(std.mem.indexOf(u8, output, "alpha") != null);
}
