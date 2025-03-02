const baseTypes = @import("./baseTypes.zig");
const std = @import("std");

pub fn readFile(allocator: std.mem.Allocator, comptime path: []const u8) anyerror!std.ArrayList(baseTypes.SourceLine) {
    const file = std.fs.cwd().openFile(path, .{}) catch |e| {
        std.debug.print("Error while opening file: {any}\n", .{e});
        return e;
    };
    defer file.close();

    var fileContent = std.ArrayList(baseTypes.SourceLine).init(allocator);

    var bufferedReader = std.io.bufferedReader(file.reader());
    var reader = bufferedReader.reader();

    var buffer: [1024]u8 = undefined;
    var lineNumber: usize = 1;
    while (try reader.readUntilDelimiterOrEof(&buffer, '\n')) |readLine| {
        const lineContent = try allocator.alloc(u8, readLine.len);
        @memcpy(lineContent, readLine);
        try fileContent.append(.{ .lineContent = lineContent, .lineNumber = lineNumber });
        lineNumber += 1;
    }

    return fileContent;
}
