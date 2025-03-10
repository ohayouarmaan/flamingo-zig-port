const std = @import("std");

pub const Keywords: []const []const u8 = &[_][]const u8{ "if", "else", "proc" };

pub const NumberType = union(enum) { integer: i64, float: f64 };

pub const TokenType = union(enum) {
    LeftCurly,
    RightCurly,
    LeftParen,
    RightParen,
    LeftSquareBrace,
    RightSquareBrace,
    Minus,
    MinusMinus,
    Plus,
    PlusPlus,
    Multiply,
    MultiplyMultiply,
    Divide,
    Equals,
    EqualsEquals,
    Exclamation,
    ExclamationEquals,
    Number: NumberType,
    SemiColon,
    String: []u8,
    Keyword: []u8,
    Identifier: []u8,
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
            .MinusMinus => try writer.print("--", .{}),
            .Plus => try writer.print("+", .{}),
            .PlusPlus => try writer.print("++", .{}),
            .Multiply => try writer.print("*", .{}),
            .MultiplyMultiply => try writer.print("**", .{}),
            .Divide => try writer.print("/", .{}),
            .Equals => try writer.print("=", .{}),
            .EqualsEquals => try writer.print("==", .{}),
            .Exclamation => try writer.print("!", .{}),
            .ExclamationEquals => try writer.print("!=", .{}),
            .SemiColon => try writer.print(";", .{}),
            .Number => |num| {
                if (num == NumberType.integer) {
                    try writer.print("integer({})", .{num.integer});
                } else {
                    try writer.print("float({})", .{num.float});
                }
            },
            .String => |str| try writer.print("STR({s})", .{str}),
            .Identifier => |str| try writer.print("indentifier({s})", .{str}),
            .Keyword => |str| try writer.print("keyword({s})", .{str}),
        }
    }
};

pub const Token = struct {
    tokenType: TokenType,
    lineNumber: usize,
    columnNumber: usize,

    pub fn format(self: Token, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
        _ = fmt;
        _ = options;
        writer.print("Token(\'{any}\', {any}:{any})", .{ self.tokenType, self.lineNumber, self.columnNumber }) catch |e| {
            std.debug.print("{any}", .{e});
        };
    }
};
