const std = @import("std");

pub fn readFile(allocator: std.mem.Allocator, comptime path: []const u8) anyerror!std.ArrayList(u8) {
    const file = std.fs.cwd().openFile(path, .{}) catch |e| {
        std.debug.print("Error while opening file: {any}\n", .{e});
        return e;
    };
    defer file.close();

    var bufferedReader = std.io.bufferedReader(file.reader());
    var fileContent: std.ArrayList(u8) = std.ArrayList(u8).init(allocator);
    var reader = bufferedReader.reader();

    while (true) {
        var buffer: [1024]u8 = undefined;
        const len = try reader.read(&buffer);
        if (len == 0) break;
        try fileContent.appendSlice(&buffer);
    }

    return fileContent;
}
