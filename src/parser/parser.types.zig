const std = @import("std");
const LexerTypes = @import("../lexer/lexer.types.zig");

pub const LiteralExpressionType = union(enum) {
    Number: LexerTypes.Token,
    pub fn format(
        self: @This(),
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        _ = fmt;
        _ = options;
        switch (self) {
            .Number => |n| try writer.print("{any}", .{n}),
        }
    }
};

pub const BinaryExpressionType = struct {
    left: *Expression,
    right: *Expression,
    operator: LexerTypes.TokenType,
    pub fn format(
        self: @This(),
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        _ = fmt;
        _ = options;
        try writer.print("{} {} {}", .{ self.left.*, self.operator, self.right.* });
    }
};

pub const Expression = union(enum) {
    LiteralExpression: *LiteralExpressionType,
    BinaryExpression: *BinaryExpressionType,
    pub fn format(
        self: @This(),
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        _ = fmt;
        _ = options;
        switch (self) {
            .BinaryExpression => |b| try writer.print("BinaryExpression({any})", .{b}),
            .LiteralExpression => |l| try writer.print("{any}", .{l}),
        }
    }
};
