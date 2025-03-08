const std = @import("std");
const LexerTypes = @import("./lexer.types.zig");

pub const LexerError = error{ OutOfBoundsAdvance, UnknownNumberParsing, UnknownStringParsing };

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

    fn appendToken(self: Lexer, tokens: *std.ArrayList(LexerTypes.Token), tokenType: LexerTypes.TokenType, line: usize) void {
        tokens.*.append(LexerTypes.Token{
            .tokenType = tokenType,
            .lineNumber = line,
            .columnNumber = self.currentIndex + 1,
        }) catch {
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
                return LexerError.UnknownNumberParsing;
            }
        }
        var number: LexerTypes.NumberType = undefined;
        if (dotCount == 1) {
            const value = std.fmt.parseFloat(f64, self.sourceCode.items[startingIndex .. endingIndex + 1]) catch {
                // std.debug.print("{any}", .{self.sourceCode.items[startingIndex .. endingIndex + 1]});
                return LexerError.UnknownNumberParsing;
            };
            number = LexerTypes.NumberType{ .float = value };
        } else {
            const value = std.fmt.parseInt(i64, self.sourceCode.items[startingIndex .. endingIndex + 1], 10) catch {
                // std.debug.print("{any}", .{self.sourceCode.items[startingIndex .. endingIndex + 1]});
                return LexerError.UnknownNumberParsing;
            };
            number = LexerTypes.NumberType{ .integer = value };
        }
        return LexerTypes.TokenType{ .Number = number };
    }

    fn buildString(self: *Lexer) LexerError!LexerTypes.TokenType {
        const startingIndex = self.currentIndex;
        var endingIndex: usize = startingIndex;
        if (self.advance() == LexerError.OutOfBoundsAdvance) {
            @panic("Error while lexing.");
        }
        while (self.sourceCode.items[self.currentIndex] != '"') {
            if (self.sourceCode.items[self.currentIndex] == '\\') {
                if (self.advance() == LexerError.OutOfBoundsAdvance) {
                    @panic("Error while lexing.");
                }
            }
            if (endingIndex - startingIndex > 45_000) {
                return LexerError.UnknownStringParsing;
            }
            if (self.advance() == LexerError.OutOfBoundsAdvance) {
                @panic("Error while lexing.");
            }
            endingIndex = self.currentIndex;
        }
        return LexerTypes.TokenType{
            .String = self.sourceCode.items[startingIndex .. endingIndex + 1],
        };
    }

    fn buildIdentifier(self: *Lexer) LexerError!LexerTypes.TokenType {
        const startingIndex = self.currentIndex;
        var endingIndex: usize = startingIndex;
        if (self.advance() == LexerError.OutOfBoundsAdvance) {
            @panic("Error while lexing.");
        }
        while ((self.sourceCode.items[self.currentIndex] >= 'a' and self.sourceCode.items[self.currentIndex] <= 'z') or self.sourceCode.items[self.currentIndex] == '_' or (self.sourceCode.items[self.currentIndex] >= 'A' and self.sourceCode.items[self.currentIndex] <= 'Z')) {
            if (endingIndex - startingIndex > 45_000) {
                return LexerError.UnknownStringParsing;
            }
            if (self.advance() == LexerError.OutOfBoundsAdvance) {
                @panic("Error while lexing.");
            }
            endingIndex = self.currentIndex;
        }
        endingIndex -= 1;
        self.currentIndex -= 1;
        for (LexerTypes.Keywords) |keyword| {
            if (std.mem.eql(u8, keyword, self.sourceCode.items[startingIndex..endingIndex])) {
                return LexerTypes.TokenType{ .Keyword = self.sourceCode.items[startingIndex .. endingIndex + 1] };
            }
        }
        return LexerTypes.TokenType{ .Identifier = self.sourceCode.items[startingIndex .. endingIndex + 1] };
    }

    fn match(self: *Lexer, toCheck: u8) bool {
        if (std.mem.eql(u8, self.sourceCode[self.currentIndex + 1], toCheck)) {
            return true;
        }
        return false;
    }

    pub fn lex(self: *Lexer, allocator: std.mem.Allocator) LexerError!std.ArrayList(LexerTypes.Token) {
        var tokens = std.ArrayList(LexerTypes.Token).init(allocator);
        var currentLine: usize = 1;
        while (self.currentIndex == 0 or self.advance() != LexerError.OutOfBoundsAdvance) {
            const currentCharacter = self.sourceCode.items[self.currentIndex];
            switch (currentCharacter) {
                '{' => {
                    self.appendToken(&tokens, LexerTypes.TokenType.LeftCurly, currentLine);
                },
                '}' => {
                    self.appendToken(&tokens, LexerTypes.TokenType.RightCurly, currentLine);
                },
                '-' => {
                    self.appendToken(&tokens, LexerTypes.TokenType.Minus, currentLine);
                },
                '+' => {
                    self.appendToken(&tokens, LexerTypes.TokenType.Plus, currentLine);
                },
                '(' => {
                    self.appendToken(&tokens, LexerTypes.TokenType.LeftParen, currentLine);
                },
                ')' => {
                    self.appendToken(&tokens, LexerTypes.TokenType.RightParen, currentLine);
                },
                '*' => {
                    self.appendToken(&tokens, LexerTypes.TokenType.Multiply, currentLine);
                },
                '0'...'9' => {
                    self.appendToken(&tokens, try self.buildNumber(), currentLine);
                },
                '"' => {
                    self.appendToken(&tokens, try self.buildString(), currentLine);
                },
                'a'...'z', 'A'...'Z', '_' => {
                    self.appendToken(&tokens, try self.buildIdentifier(), currentLine);
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
