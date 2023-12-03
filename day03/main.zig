const std = @import("std");

// const input =
//     \\467..114..
//     \\...*......
//     \\..35..633.
//     \\......#...
//     \\617*......
//     \\.....+.58.
//     \\..592.....
//     \\......755.
//     \\...$.*....
//     \\.664.598..
// ;
const input = @embedFile("./input.txt");

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
        var sum: usize = 0;
        for (self.lines.items) |line| {
            for (line) |char| {
                switch (char) {
                    '0'...'9', '.' => {},
                    else => {
                        // get all numbers around this char\
                        const @"sum around" = self.sumAround();

                        // std.debug.print("char: {c} -> {d}\n", .{ char, @"sum around" });
                        sum += @"sum around";
                    },
                }
                self.idx += 1;
            }
            self.lineNumber += 1;
            self.idx = 0;
        }

        std.debug.print("{d}\n", .{sum});
    }

    /// Sum of all numbers around a point
    fn sumAround(self: Obj) usize {
        const top = if (self.lineNumber > 0) blk: {
            const line = self.lines.items[self.lineNumber - 1];
            const sum = self.sumPeaks(line);
            break :blk sum;
        } else 0;
        const bottom = if (self.lineNumber >= self.lines.items.len) 0 else blk: {
            const line = self.lines.items[self.lineNumber + 1];
            const sum = self.sumPeaks(line);
            break :blk sum;
        };

        const left = switch (Token.fromChar(self.lines.items[self.lineNumber][self.idx - 1])) {
            .number => blk: {
                var start: usize = self.idx - 1;
                while (start > 0) {
                    switch (Token.fromChar(self.lines.items[self.lineNumber][start - 1])) {
                        .number => start -= 1,
                        else => break,
                    }
                }
                const number = std.fmt.parseInt(usize, self.lines.items[self.lineNumber][start..self.idx], 10) catch unreachable;
                std.debug.print("num: {d}\n", .{number});
                break :blk number;
            },
            else => 0,
        };
        const right = switch (Token.fromChar(self.lines.items[self.lineNumber][self.idx + 1])) {
            .number => blk: {
                var end: usize = self.idx + 1;
                while (end > 0) {
                    switch (Token.fromChar(self.lines.items[self.lineNumber][end + 1])) {
                        .number => end += 1,
                        else => break,
                    }
                }
                const number = std.fmt.parseInt(usize, self.lines.items[self.lineNumber][self.idx + 1 .. end + 1], 10) catch unreachable;
                std.debug.print("num: {d}\n", .{number});
                break :blk number;
            },
            else => 0,
        };

        return top + bottom + left + right;
    }
    fn sumPeaks(self: Obj, line: []const u8) usize {
        // std.debug.print("line: {s}\n", .{line});
        const middleOccupied = Token.fromChar(line[self.idx]) == .number;

        const left = blk: {
            switch (Token.fromChar(line[self.idx - 1])) {
                .number => {
                    var start: usize = self.idx - 1;
                    while (start > 0) {
                        switch (Token.fromChar(line[start - 1])) {
                            .number => start -= 1,
                            else => break,
                        }
                    }
                    var end: usize = self.idx - 1;
                    while (end < line.len) {
                        switch (Token.fromChar(line[end + 1])) {
                            .number => end += 1,
                            else => break,
                        }
                    }
                    const number = std.fmt.parseInt(usize, line[start .. end + 1], 10) catch unreachable;
                    std.debug.print("num: {d}\n", .{number});
                    break :blk number;
                },
                else => break :blk 0,
            }
        };

        var start: usize = self.idx + 1;
        const right: usize = blk: {
            if (middleOccupied and left != 0) break :blk 0;
            switch (Token.fromChar(line[start])) {
                .number => {
                    while (start >= self.idx - 1) {
                        switch (Token.fromChar(line[start - 1])) {
                            .number => start -= 1,
                            else => break,
                        }
                    }

                    var end: usize = start + 1;
                    while (end < line.len) {
                        switch (Token.fromChar(line[end])) {
                            .number => end += 1,
                            else => break,
                        }
                    }
                    const number = std.fmt.parseInt(usize, line[start..end], 10) catch unreachable;
                    std.debug.print("num: {d}\n", .{number});
                    break :blk number;
                },
                else => break :blk 0,
            }
        };

        return left + right;
    }

    fn sumNumbers(self: Obj) usize {
        var total: usize = 0;
        for (self.numbers.items) |number| {
            total += number;
        }
        return total;
    }
};

const Token = enum {
    number,
    star,
    item,
    empty,

    fn fromChar(char: u8) Token {
        return switch (char) {
            '0'...'9' => Token.number,
            '*' => Token.star,
            '.' => Token.empty,
            else => Token.item,
        };
    }
};
