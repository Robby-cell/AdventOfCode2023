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

pub fn main() !void {
    std.debug.print("{d}\n", .{getSumOfCalibration(input)});
}

fn getSumOfCalibration(buffer: []const u8) u32 {
    var lines = std.mem.split(u8, buffer, "\n");
    var total: u32 = 0;
    while (lines.next()) |line| {
        const lineScore = part2(line);
        std.debug.print("{d}\n", .{lineScore});
        total += lineScore;
    }

    return total;
}

fn part2(line: []const u8) u8 {
    const startsWith = std.mem.startsWith;

    var first: ?u8 = null;
    var last: ?u8 = null;
    var idx: u32 = 0;

    while (true) {
        if (idx >= line.len)
            break;

        switch (line[idx]) {
            '0'...'9' => {
                if (first) |_| {} else {
                    first = line[idx] - 0x30;
                }
                last = line[idx] - 0x30;
                idx += 1;
            },
            'o' => {
                if (startsWith(u8, line[idx..line.len], "one")) {
                    idx += 1;
                    if (first) |_| {} else {
                        first = 1;
                    }

                    last = 1;
                } else {
                    idx += 1;
                }
            },
            't' => {
                if (startsWith(u8, line[idx..line.len], "two")) {
                    idx += 1;
                    if (first) |_| {} else {
                        first = 2;
                    }

                    last = 2;
                } else if (startsWith(u8, line[idx..line.len], "three")) {
                    idx += 1;
                    if (first) |_| {} else {
                        first = 3;
                    }
                    last = 3;
                } else {
                    idx += 1;
                }
            },
            'f' => {
                if (startsWith(u8, line[idx..line.len], "four")) {
                    idx += 1;
                    if (first) |_| {} else {
                        first = 4;
                    }

                    last = 4;
                } else if (startsWith(u8, line[idx..line.len], "five")) {
                    idx += 1;
                    if (first) |_| {} else {
                        first = 5;
                    }
                    last = 5;
                } else {
                    idx += 1;
                }
            },
            's' => {
                if (startsWith(u8, line[idx..line.len], "six")) {
                    idx += 1;
                    if (first) |_| {} else {
                        first = 6;
                    }

                    last = 6;
                } else if (startsWith(u8, line[idx..line.len], "seven")) {
                    idx += 1;
                    if (first) |_| {} else {
                        first = 7;
                    }
                    last = 7;
                } else {
                    idx += 1;
                }
            },
            'e' => {
                if (startsWith(u8, line[idx..line.len], "eight")) {
                    idx += 1;
                    if (first) |_| {} else {
                        first = 8;
                    }

                    last = 8;
                } else {
                    idx += 1;
                }
            },
            'n' => {
                if (startsWith(u8, line[idx..line.len], "nine")) {
                    idx += 1;
                    if (first) |_| {} else {
                        first = 9;
                    }

                    last = 9;
                } else {
                    idx += 1;
                }
            },

            else => idx += 1,
        }
    }
    return (first orelse 0) * 10 + (last orelse 0);
}

/// part 1
fn getFirstAndLastNumber(line: []const u8) u8 {
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
