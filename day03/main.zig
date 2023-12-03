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

// const input = @embedFile("./input.txt");

// const input =
//     \\123..*77.
//     \\12...*...
// ;

const input =
    \\.........*........951...3....*.................623.263.............=.-....122..........................=....519*...........692.......%313...
    \\........943.......*......$....990.......795..../......*..135.....815.483....*..937*.............................634..............771........
;

pub fn main() !void {
    var rawGpa: std.heap.GeneralPurposeAllocator(.{}) = .{};
    defer _ = rawGpa.deinit();
    const allocator = rawGpa.allocator();

    var obj = try Obj.init(allocator, input);
    defer obj.deinit();

    try obj.part1();

    // std.debug.print("{s}", .{obj.lines.items});
}

const Number = struct {
    line: usize,
    start: usize,
    end: usize,
};
const Obj = struct {
    const @"lines type" = std.ArrayList([]const u8);

    lines: @"lines type" = undefined,
    numbers: std.AutoHashMap(Number, void) = undefined,
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
            .numbers = std.AutoHashMap(Number, void).init(allocator),
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
    fn part1(self: *Obj) !void {
        for (self.lines.items) |line| {
            for (line) |char| {
                switch (char) {
                    '0'...'9', '.' => {},
                    else => {
                        // get all numbers around this char\
                        try self.sumAround();

                        // std.debug.print("char: {c} -> {d}\n", .{ char, @"sum around" });
                    },
                }
                self.idx += 1;
            }
            self.lineNumber += 1;
            self.idx = 0;
        }

        var items = self.numbers.iterator();
        var total: usize = 0;
        while (items.next()) |item| {
            const key = item.key_ptr;
            total += std.fmt.parseInt(usize, self.lines.items[key.line][key.start..key.end], 10) catch unreachable;
        }
        std.debug.print("{d}\n", .{total});
    }

    /// Sum of all numbers around a point
    fn sumAround(self: *Obj) !void {
        if (self.lineNumber > 0) {
            const line = self.lines.items[self.lineNumber - 1];
            try self.sumPeaks(line, self.lineNumber - 1);
        }
        if (self.lineNumber + 1 < self.lines.items.len) {
            const line = self.lines.items[self.lineNumber + 1];
            try self.sumPeaks(line, self.lineNumber + 1);
        }

        switch (Token.fromChar(self.lines.items[self.lineNumber][self.idx - 1])) {
            .number => {
                var start: usize = self.idx - 1;
                while (start > 0) {
                    switch (Token.fromChar(self.lines.items[self.lineNumber][start - 1])) {
                        .number => start -= 1,
                        else => break,
                    }
                }
                try self.numbers.put(.{ .start = start, .end = self.idx, .line = self.lineNumber }, undefined);
            },
            else => {},
        }
        switch (Token.fromChar(self.lines.items[self.lineNumber][self.idx + 1])) {
            .number => {
                var end: usize = self.idx + 1;
                while (end > 0) {
                    switch (Token.fromChar(self.lines.items[self.lineNumber][end + 1])) {
                        .number => end += 1,
                        else => break,
                    }
                }
                try self.numbers.put(.{ .start = self.idx + 1, .end = end + 1, .line = self.lineNumber }, undefined);
            },
            else => {},
        }
    }
    fn sumPeaks(self: *Obj, line: []const u8, lineNumber: usize) !void {
        // std.debug.print("line: {s}\n", .{line});

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
                try self.numbers.put(.{ .start = start, .end = end + 1, .line = lineNumber }, undefined);
            },
            else => {},
        }

        var start: usize = self.idx + 1;
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
                try self.numbers.put(.{ .start = start, .end = end, .line = lineNumber }, undefined);
            },
            else => {},
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
