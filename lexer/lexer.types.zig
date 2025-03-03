const std = @import("std");

pub const NumberType = union(enum) { integer: i64, float: f64 };

pub const TokenType = union(enum) {
    LeftCurly,
    RightCurly,
    LeftParen,
    RightParen,
    LeftSquareBrace,
    RightSquareBrace,
    Minus,
    Plus,
    Multiply,
    Number: NumberType,
    String: std.ArrayList(u8),
    pub fn format(self: TokenType, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
        _ = fmt;
        _ = options;
        switch (self) {
            .LeftCurly => try writer.print("{{", .{}),
            .RightCurly => try writer.print("}}", .{}),
            .LeftParen => try writer.print("(", .{}),
            .RightParen => try writer.print(")", .{}),
            .LeftSquareBrace => try writer.print("[", .{}),
            .RightSquareBrace => try writer.print("]", .{}),
            .Minus => try writer.print("-", .{}),
            .Plus => try writer.print("+", .{}),
            .Multiply => try writer.print("*", .{}),
            .Number => |num| {
                if (num == NumberType.integer) {
                    try writer.print("integer({})", .{num.integer});
                } else {
                    try writer.print("float({})", .{num.float});
                }
            },
            .String => |str| try writer.print("STR({})", .{str}),
        }
    }
};

pub const Token = struct {
    tokenType: TokenType,
    lineNumber: usize,

    pub fn format(self: Token, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
        _ = fmt;
        _ = options;
        try writer.print("Token({any}, {})", .{ self.tokenType, self.lineNumber });
    }
};
