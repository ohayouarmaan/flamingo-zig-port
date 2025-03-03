const std = @import("std");
const LexerTypes = @import("./lexer.types.zig");

pub const LexerError = error{ OutOfBoundsAdvance, UnknownNumberParsing };

pub const Lexer = struct {
    sourceCode: std.ArrayList(u8),
    currentIndex: usize,

    pub fn advance(self: *Lexer) LexerError!void {
        if (self.currentIndex < self.sourceCode.items.len - 1) {
            self.currentIndex += 1;
        } else {
            return LexerError.OutOfBoundsAdvance;
        }
    }

    fn appendToken(tokens: *std.ArrayList(LexerTypes.Token), tokenType: LexerTypes.TokenType, line: usize) void {
        tokens.*.append(LexerTypes.Token{ .tokenType = tokenType, .lineNumber = line }) catch {
            @panic("UNREACHABLE");
        };
    }

    fn buildNumber(self: *Lexer) !LexerTypes.TokenType {
        const startingIndex = self.currentIndex;
        var endingIndex: usize = undefined;
        var dotCount: u8 = 0;
        while ((self.sourceCode.items[self.currentIndex] >= '0' and
            self.sourceCode.items[self.currentIndex] <= '9') or
            (self.sourceCode.items[self.currentIndex] == '.'))
        {
            if (self.sourceCode.items[self.currentIndex] == '.') {
                dotCount += 1;
            }
            if (dotCount > 1) {
                return LexerError.UnknownNumberParsing;
            }
            endingIndex = self.currentIndex;
            if (self.advance() == LexerError.OutOfBoundsAdvance) {
                @panic("Error while parsing number, unexpected end of the file.");
            }
        }
        var number: LexerTypes.NumberType = undefined;
        if (dotCount == 1) {
            const value = std.fmt.parseFloat(f64, self.sourceCode.items[startingIndex .. endingIndex + 1]) catch {
                std.debug.print("{any}", .{self.sourceCode.items[startingIndex .. endingIndex + 1]});
                return LexerError.UnknownNumberParsing;
            };
            number = LexerTypes.NumberType{ .float = value };
        } else {
            const value = std.fmt.parseInt(i64, self.sourceCode.items[startingIndex .. endingIndex + 1], 10) catch {
                std.debug.print("{s}", .{self.sourceCode.items[startingIndex .. endingIndex + 1]});
                return LexerError.UnknownNumberParsing;
            };
            number = LexerTypes.NumberType{ .integer = value };
        }
        return LexerTypes.TokenType{ .Number = number };
    }

    pub fn lex(self: *Lexer, allocator: std.mem.Allocator) LexerError!std.ArrayList(LexerTypes.Token) {
        var tokens = std.ArrayList(LexerTypes.Token).init(allocator);
        var currentLine: usize = 1;
        while (self.advance() != LexerError.OutOfBoundsAdvance) {
            const currentCharacter = self.sourceCode.items[self.currentIndex];
            switch (currentCharacter) {
                '{' => {
                    Lexer.appendToken(&tokens, LexerTypes.TokenType.LeftCurly, currentLine);
                },
                '}' => {
                    Lexer.appendToken(&tokens, LexerTypes.TokenType.RightCurly, currentLine);
                },
                '-' => {
                    Lexer.appendToken(&tokens, LexerTypes.TokenType.Minus, currentLine);
                },
                '+' => {
                    Lexer.appendToken(&tokens, LexerTypes.TokenType.Plus, currentLine);
                },
                '(' => {
                    Lexer.appendToken(&tokens, LexerTypes.TokenType.LeftParen, currentLine);
                },
                ')' => {
                    Lexer.appendToken(&tokens, LexerTypes.TokenType.RightParen, currentLine);
                },
                '*' => {
                    Lexer.appendToken(&tokens, LexerTypes.TokenType.Multiply, currentLine);
                },
                '0'...'9' => {
                    Lexer.appendToken(&tokens, self.buildNumber() catch |e| {
                        std.debug.print("{any}", .{e});
                        @panic("WTF");
                    }, currentLine);
                },
                '\n' => {
                    currentLine += 1;
                },
                else => {},
            }
        }

        return tokens;
    }
};
