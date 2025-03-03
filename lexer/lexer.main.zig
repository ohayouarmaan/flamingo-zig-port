const std = @import("std");
const LexerTypes = @import("./lexer.types.zig");

pub const LexerError = error{
    OutOfBoundsAdvance,
};

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
    pub fn lex(self: *Lexer, allocator: std.mem.Allocator) LexerError!std.ArrayList(LexerTypes.Token) {
        var tokens = std.ArrayList(LexerTypes.Token).init(allocator);
        var currentLine: usize = 1;
        while (self.advance() != LexerError.OutOfBoundsAdvance) {
            const currentCharacter = self.sourceCode.items[self.currentIndex];
            switch (currentCharacter) {
                '{' => {
                    tokens.append(LexerTypes.Token{
                        .tokenType = LexerTypes.TokenType.LeftCurly,
                        .lineNumber = currentLine,
                    }) catch {
                        return LexerError.OutOfBoundsAdvance;
                    };
                },
                '}' => {
                    tokens.append(LexerTypes.Token{
                        .tokenType = LexerTypes.TokenType.RightCurly,
                        .lineNumber = currentLine,
                    }) catch {
                        return LexerError.OutOfBoundsAdvance;
                    };
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
