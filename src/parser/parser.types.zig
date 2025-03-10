const std = @import("std");
const LexerTypes = @import("../lexer/lexer.types.zig");

pub const LiteralExpressionType = union(enum) {
    Number: LexerTypes.Token,
    pub fn deinit(self: *const LiteralExpressionType, allocator: std.mem.Allocator) void {
        std.debug.print("Deinit LiteralExpressionType({*})\n", .{self});
        allocator.destroy(self);
    }
};

pub const BinaryExpressionType = struct {
    left: *Expression,
    right: *Expression,
    operator: LexerTypes.TokenType,

    pub fn deinit(self: *const BinaryExpressionType, allocator: std.mem.Allocator) void {
        std.debug.print("Deinit BinaryExpressionType({*})\n", .{self});
        self.left.*.deinit(allocator);
        std.debug.print("Destroy Expression({*}) is redundant\n", .{self.left});
        //allocator.destroy(self.left);

        self.right.*.deinit(allocator);
        //allocator.destroy(self.right);
        std.debug.print("Destroy Expression({*}) is redundant\n", .{self.right});
        allocator.destroy(self); // Frees self first
    }
};

pub const Expression = union(enum) {
    LiteralExpression: *LiteralExpressionType,
    BinaryExpression: *BinaryExpressionType,
    pub fn deinit(self: *const Expression, allocator: std.mem.Allocator) void {
        std.debug.print("Deinit Expression({*})\n", .{self});
        switch (self.*) {
            .LiteralExpression => |l| {
                l.deinit(allocator);
            },
            .BinaryExpression => |b| {
                b.deinit(allocator);
            },
        }

        std.debug.print("Destroy Expression({*})\n", .{self});
        allocator.destroy(self); // Frees self again
    }
};
