const std = @import("std");
const baseTypes = @import("./utils/baseTypes.zig");
const helpers = @import("./utils/helperFunctions.zig");

const MAX_LINE_LENGTH = 4096;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    const fileContent = try helpers.readFile(allocator, "./test.fl");
    std.debug.print("{any}", .{fileContent.items});
    defer {
        for (fileContent.items) |sourceLine| {
            allocator.free(sourceLine.lineContent);
        }
        fileContent.deinit();
    }
}
