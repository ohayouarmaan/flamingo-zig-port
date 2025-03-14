const std = @import("std");
const helpers = @import("./utils/helperFunctions.zig");
const lexer = @import("./lexer/lexer.main.zig");
const parser = @import("./parser/parser.main.zig");
const ParserType = @import("./parser/parser.types.zig");
const compiler = @import("./compiler/compiler.main.zig");

pub fn main() !void {
    var aa = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer _ = aa.deinit();

    const allocator = aa.allocator();
    const fileContent = try helpers.readFile(allocator, "./test.fl");
    defer fileContent.deinit();

    var Lexer = lexer.Lexer{
        .sourceCode = fileContent,
        .currentIndex = 0,
    };

    const tokens = try Lexer.lex(allocator);
    defer tokens.deinit();

    var Parser = try parser.Parser.init(&tokens, allocator);
    _ = try Parser.parse();

    var Compiler = compiler.Compiler.init(allocator, Parser.program);
    const t = try Compiler.compile(&Parser.program);

    std.debug.print("compiled : {s}\n", .{t});
}
