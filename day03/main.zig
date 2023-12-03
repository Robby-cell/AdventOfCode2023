const std = @import("std");

const input =
    \\467..114..
    \\...*......
    \\..35..633.
    \\......#...
    \\617*......
    \\.....+.58.
    \\..592.....
    \\......755.
    \\...$.*....
    \\.664.598..
;
// const input = @embedFile("./input.txt");

pub fn main() !void {
    var rawGpa: std.heap.GeneralPurposeAllocator(.{}) = .{};
    defer _ = rawGpa.deinit();
    const allocator = rawGpa.allocator();

    var obj = try Obj.init(allocator, input);
    defer obj.deinit();

    try obj.getNumbers();

    // std.debug.print("{s}", .{obj.lines.items});
}

const Obj = struct {
    lines: std.ArrayList([]const u8) = undefined,
    numbers: std.ArrayList(usize) = undefined,
    line: usize = 0,
    idx: usize = 0,

    /// Initialize the struct, splits the buffer into its lines and stores
    /// in `std.ArrayList([]const u8)`
    fn init(allocator: std.mem.Allocator, buffer: []const u8) !Obj {
        var lines = std.ArrayList([]const u8).init(allocator);
        var splitLines = std.mem.splitSequence(u8, buffer, "\n");
        while (splitLines.next()) |line| {
            try lines.append(line);
        }

        return .{
            .lines = lines,
            .numbers = std.ArrayList(usize).init(allocator),
        };
    }
    /// Free members of the struct
    fn deinit(self: *Obj) void {
        self.numbers.deinit();
        self.lines.deinit();
    }

    /// Get all valid numbers
    fn getNumbers(self: *Obj) !void {
        _ = self;
    }
};
