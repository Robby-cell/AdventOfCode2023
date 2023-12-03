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

    obj.part1();

    // std.debug.print("{s}", .{obj.lines.items});
}

const Obj = struct {
    const @"lines type" = std.ArrayList([]const u8);
    const @"numbers type" = std.ArrayList(usize);

    lines: @"lines type" = undefined,
    numbers: @"numbers type" = undefined,
    lineNumber: usize = 0,
    idx: usize = 0,

    /// Initialize the struct, splits the buffer into its lines and stores
    /// in `std.ArrayList([]const u8)`
    fn init(allocator: std.mem.Allocator, buffer: []const u8) !Obj {
        var lines = @"lines type".init(allocator);
        var splitLines = std.mem.splitSequence(u8, buffer, "\n");
        while (splitLines.next()) |line| {
            try lines.append(line);
        }

        return .{
            .lines = lines,
            .numbers = @"numbers type".init(allocator),
        };
    }
    /// Free members of the struct
    fn deinit(self: *Obj) void {
        self.numbers.deinit();
        self.lines.deinit();
    }
    /// Reset to do part 2
    fn reset(self: *Obj) void {
        self.numbers.clearAndFree();
        self.lineNumber = 0;
        self.idx = 0;
    }

    /// Get all valid numbers
    fn part1(self: *Obj) void {
        for (self.lines.items) |line| {
            for (line) |char| {
                switch (char) {
                    '0'...'9', '.' => {},
                    else => {
                        // get all numbers around this char
                    },
                }
                self.idx += 1;
            }
            self.lineNumber += 1;
            self.idx = 0;
        }
    }

    fn sumNumbers(self: Obj) usize {
        var total: usize = 0;
        for (self.numbers.items) |number| {
            total += number;
        }
        return total;
    }
};
