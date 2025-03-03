const std = @import("std");
const helpers = @import("./utils/helperFunctions.zig");
const lexer = @import("./lexer/lexer.main.zig");

const MAX_LINE_LENGTH = 4096;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();
    const fileContent = try helpers.readFile(allocator, "./test.fl");
    defer fileContent.deinit();

    var Lexer = lexer.Lexer{
        .sourceCode = fileContent,
        .currentIndex = 0,
    };
    const tokens = try Lexer.lex(allocator);
    defer tokens.deinit();

    std.debug.print("{any}", .{tokens.items});
}
