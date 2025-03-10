const std = @import("std");
const ParserTypes = @import("./parser.types.zig");
const LexerTypes = @import("../lexer/lexer.types.zig");

pub const Parser = struct {
    tokens: *const std.ArrayList(LexerTypes.Token),
    program: ParserTypes.Expression,
    allocator: std.mem.Allocator,
    currentIndex: usize,

    pub fn init(tokens: *const std.ArrayList(LexerTypes.Token), allocator: std.mem.Allocator) !Parser {
        return Parser{
            .tokens = tokens,
            .program = undefined,
            .allocator = allocator,
            .currentIndex = 0,
        };
    }

    pub fn parse(self: *Parser) !void {
        self.program = try self.expression();
    }

    fn matchTokens(self: *Parser, tt: []const LexerTypes.TokenType) bool {
        if (self.currentIndex + 1 >= self.tokens.items.len) return false;

        const current_tag = @tagName(self.tokens.items[self.currentIndex + 1].tokenType);

        for (tt) |token| {
            if (std.mem.eql(u8, @tagName(token), current_tag)) {
                return true;
            }
        }

        return false;
    }

    fn createBinaryExpression(self: *Parser, comptime precedentFn: fn (*Parser) anyerror!ParserTypes.Expression, comptime tokens: []const LexerTypes.TokenType) !ParserTypes.Expression {
        var lhs_ptr = try self.allocator.create(ParserTypes.Expression);
        errdefer self.allocator.destroy(lhs_ptr);
        lhs_ptr.* = try precedentFn(self);

        while (self.matchTokens(tokens)) {
            self.currentIndex += 1;
            const operator = self.tokens.items[self.currentIndex].tokenType;
            self.currentIndex += 1;

            const rhs_ptr = try self.allocator.create(ParserTypes.Expression);
            errdefer self.allocator.destroy(rhs_ptr);
            rhs_ptr.* = try precedentFn(self);

            const binary_expr = try self.allocator.create(ParserTypes.Expression);
            errdefer self.allocator.destroy(binary_expr);

            const binaryExprType = try self.allocator.create(ParserTypes.BinaryExpressionType);
            errdefer self.allocator.destroy(binaryExprType);

            binaryExprType.* = .{
                .left = lhs_ptr,
                .right = rhs_ptr,
                .operator = operator,
            };

            binary_expr.* = .{
                .BinaryExpression = binaryExprType,
            };

            lhs_ptr = binary_expr;
        }

        return lhs_ptr.*;
    }

    fn expression(self: *Parser) !ParserTypes.Expression {
        return self.equality();
    }

    fn equality(self: *Parser) !ParserTypes.Expression {
        const eq_tt = [_]LexerTypes.TokenType{
            LexerTypes.TokenType.EqualsEquals,
            LexerTypes.TokenType.ExclamationEquals,
        };
        return self.createBinaryExpression(Parser.term, eq_tt[0..]);
    }

    fn term(self: *Parser) !ParserTypes.Expression {
        const term_tt = [_]LexerTypes.TokenType{
            LexerTypes.TokenType.Minus,
            LexerTypes.TokenType.Plus,
        };
        return self.createBinaryExpression(Parser.factor, term_tt[0..]);
    }

    fn factor(self: *Parser) !ParserTypes.Expression {
        const factor_tt = [_]LexerTypes.TokenType{
            LexerTypes.TokenType.Multiply,
            LexerTypes.TokenType.Divide,
        };
        return self.createBinaryExpression(Parser.primary, factor_tt[0..]);
    }

    fn primary(self: *Parser) !ParserTypes.Expression {
        switch (self.tokens.items[self.currentIndex].tokenType) {
            .Number => |_| {
                const mainExpression = try self.allocator.create(ParserTypes.Expression);
                errdefer self.allocator.destroy(mainExpression); // Ensure mainExpression is freed on error

                const literalExpressionPtr = try self.allocator.create(ParserTypes.LiteralExpressionType);
                errdefer self.allocator.destroy(literalExpressionPtr); // Ensure literalExpressionPtr is freed on error

                literalExpressionPtr.* = .{
                    .Number = self.tokens.items[self.currentIndex],
                };

                mainExpression.* = .{
                    .LiteralExpression = literalExpressionPtr,
                };

                return mainExpression.*;
            },
            else => {
                @panic("UNHANDLED");
            },
        }
    }

    pub fn deinit(self: *Parser) void {
        self.program.deinit(self.allocator);
        // self.allocator.destroy(&self.program);
    }
};
