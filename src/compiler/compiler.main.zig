const ParserTypes = @import("../parser/parser.types.zig");
const std = @import("std");
const CompilerError = error{OutOfMemory};

pub const Compiler = struct {
    ast: ParserTypes.Expression,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator, ast: ParserTypes.Expression) Compiler {
        return Compiler{
            .allocator = allocator,
            .ast = ast,
        };
    }

    fn emit_binary_expression(self: *Compiler, exp: *ParserTypes.BinaryExpressionType) CompilerError![]u8 {
        const lhs = try self.compile(exp.left);
        const rhs = try self.compile(exp.right);
        switch (exp.operator) {
            .Plus => {
                return try std.fmt.allocPrint(self.allocator, "{s} {s} ADD\n", .{ lhs[0..], rhs[0..] });
            },
            .Minus => {
                return try std.fmt.allocPrint(self.allocator, "{s} {s} MINUS\n", .{ lhs[0..], rhs[0..] });
            },
            .Multiply => {
                return try std.fmt.allocPrint(self.allocator, "{s} {s} MULTIPLY\n", .{ lhs[0..], rhs[0..] });
            },
            .Divide => {
                return try std.fmt.allocPrint(self.allocator, "{s} {s} DIVIDE\n", .{ lhs[0..], rhs[0..] });
            },
            else => {},
        }
        @panic("UNREACHABLE");
    }

    fn emit_literal_expression(self: *Compiler, exp: *ParserTypes.LiteralExpressionType) CompilerError![]u8 {
        switch (exp.*) {
            .Number => |x| {
                switch (x.tokenType) {
                    .Number => |NumberToken| {
                        switch (NumberToken) {
                            .integer => |i| {
                                return try std.fmt.allocPrint(self.allocator, "PUSH {d}\n", .{i});
                            },
                            .float => |f| {
                                return try std.fmt.allocPrint(self.allocator, "PUSH {d}\n", .{f});
                            },
                        }
                    },
                    else => {},
                }
            },
        }
        @panic("UNREACHABLE");
    }

    pub fn compile(self: *Compiler, exp: *ParserTypes.Expression) ![]u8 {
        switch (exp.*) {
            .BinaryExpression => |b| {
                return try self.emit_binary_expression(b);
            },
            .LiteralExpression => |l| {
                return try self.emit_literal_expression(l);
            },
        }
        @panic("UNREACHABLE");
    }

    pub fn deinit(self: *Compiler) !void {
        try self.allocator.deinit();
    }
};
