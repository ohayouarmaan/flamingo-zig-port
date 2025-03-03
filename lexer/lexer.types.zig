const std = @import("std");

pub const TokenType = union(enum) {
    LeftCurly,
    RightCurly,
    LeftParen,
    RightParen,
    LeftSquareBrace,
    RightSquareBrace,
    Minus,
    Plus,
    Number: u8,
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
            .Number => |num| try writer.print("NUM({})", .{num}),
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
