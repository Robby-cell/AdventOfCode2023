const std = @import("std");

const input = @embedFile("./input.txt");
// const input =
//     \\two1nine
//     \\eightwothree
//     \\abcone2threexyz
//     \\xtwone3four
//     \\4nineeightseven2
//     \\zoneight234
//     \\7pqrstsixteen
// ;
var fnPtr: *const fn ([]const u8) u8 = undefined;

pub fn main() void {
    var args = std.process.args();
    _ = args.next();
    const part = args.next() orelse "part1";
    fnPtr = if (std.mem.eql(u8, part, "part2")) part2 else part1;

    std.debug.print("{d}\n", .{getSumOfCalibration(input)});
}

fn getSumOfCalibration(buffer: []const u8) u32 {
    var lines = std.mem.split(u8, buffer, "\n");
    var total: u32 = 0;
    while (lines.next()) |line| {
        const lineScore = fnPtr(line);
        total += lineScore;
    }

    return total;
}

fn part2(line: []const u8) u8 {
    const startsWith = std.mem.startsWith;

    var first: ?u8 = null;
    var last: ?u8 = null;

    for (line, 0..) |_, idx| {
        switch (line[idx]) {
            '0'...'9' => {
                if (first) |_| {} else {
                    first = line[idx] - 0x30;
                }
                last = line[idx] - 0x30;
            },
            else => {
                if (startsWith(u8, line[idx..line.len], "one")) {
                    first = first orelse 1;
                    last = 1;
                } else if (startsWith(u8, line[idx..line.len], "two")) {
                    first = first orelse 2;
                    last = 2;
                } else if (startsWith(u8, line[idx..line.len], "three")) {
                    first = first orelse 3;
                    last = 3;
                } else if (startsWith(u8, line[idx..line.len], "four")) {
                    first = first orelse 4;
                    last = 4;
                } else if (startsWith(u8, line[idx..line.len], "five")) {
                    first = first orelse 5;
                    last = 5;
                } else if (startsWith(u8, line[idx..line.len], "six")) {
                    first = first orelse 6;
                    last = 6;
                } else if (startsWith(u8, line[idx..line.len], "seven")) {
                    first = first orelse 7;
                    last = 7;
                } else if (startsWith(u8, line[idx..line.len], "eight")) {
                    first = first orelse 8;
                    last = 8;
                } else if (startsWith(u8, line[idx..line.len], "nine")) {
                    first = first orelse 9;
                    last = 9;
                }
            },
        }
    }
    return (first orelse 0) * 10 + (last orelse 0);
}

/// part 1
fn part1(line: []const u8) u8 {
    var first: ?u8 = null;
    var last: ?u8 = null;

    for (line) |char| {
        switch (char) {
            '0'...'9' => {
                if (first) |_| {} else {
                    first = char - 0x30;
                }

                last = char - 0x30;
            },
            else => {},
        }
    }
    return (first orelse 0) * 10 + (last orelse 0);
}

test "simple test" {
    const expect = std.testing.expect;
    const testInput =
        \\two1nine
        \\eightwothree
        \\abcone2threexyz
        \\xtwone3four
        \\4nineeightseven2
        \\zoneight234
        \\7pqrstsixteen
    ;
    try expect(getSumOfCalibration(testInput) == 281);
}
