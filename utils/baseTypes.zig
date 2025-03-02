const std = @import("std");

pub const SourceLine = struct {
    lineContent: []u8,
    lineNumber: usize,
    pub fn format(self: SourceLine, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
        _ = fmt;
        _ = options;
        try writer.print("Line({}, \"{s}\")", .{ self.lineNumber, self.lineContent });
    }
};
