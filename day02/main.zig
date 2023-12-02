const std = @import("std");

const input = @embedFile("./input.txt");
// const input =
//     \\Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
//     \\Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
//     \\Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
//     \\Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
//     \\Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
// ;

pub fn main() void {
    std.debug.print("{d}\n", .{part2(input)});
}

/// find all possible games, and sum the IDs of those games
fn findPossible(inputStr: []const u8) u32 {
    var lines = std.mem.split(u8, inputStr, "\n");

    var id: u32 = 1;
    var total: u32 = 0;
    while (lines.next()) |line| : (id += 1) {
        if (possible(line)) {
            std.debug.print("{d}\n", .{id});
            total += id;
        }
    }

    return total;
}

fn part2(inputStr: []const u8) u32 {
    var lines = std.mem.split(u8, inputStr, "\n");

    var total: u32 = 0;
    while (lines.next()) |line| {
        total += part2perLine(line);
    }

    return total;
}

fn part2perLine(line: []const u8) u32 {
    if (line.len < 5) return 0;

    // skip game
    var idx: usize = 0;
    while (true) {
        switch (line[idx]) {
            'G', 'a', 'm', 'e' => idx += 1,
            ' ' => idx += 1,
            '0'...'9' => idx += 1,

            ':' => {
                idx += 2;
                break;
            },

            else => unreachable,
        }
    }

    var cachedNumber: u32 = 0;
    var rgb: [3]u32 = .{ 0, 0, 0 };

    while (idx < line.len) : (idx += 1) {
        switch (line[idx]) {
            // skip whitespace
            ' ' => {},

            '0'...'9' => |char| {
                cachedNumber = (cachedNumber * 10) + (char - 0x30);
            },

            'r' => {
                rgb[0] = @max(rgb[0], cachedNumber);
                cachedNumber = 0;
                idx += 2;
            },

            'g' => {
                rgb[1] = @max(rgb[1], cachedNumber);
                cachedNumber = 0;
                idx += 4;
            },

            'b' => {
                rgb[2] = @max(rgb[2], cachedNumber);
                cachedNumber = 0;
                idx += 3;
            },

            ',' => {},

            ';' => {},

            else => unreachable,
        }
    }
    return rgb[0] * rgb[1] * rgb[2];
}

fn possible(line: []const u8) bool {
    if (line.len < 5) return false;
    const isValid = struct {
        fn valid(rgbValues: [3]u32) bool {
            if (rgbValues[0] > 12)
                return false;
            if (rgbValues[1] > 13)
                return false;
            if (rgbValues[2] > 14)
                return false;
            return true;
        }
    }.valid;

    // skip game
    var idx: usize = 0;
    while (true) {
        switch (line[idx]) {
            'G', 'a', 'm', 'e' => idx += 1,
            ' ' => idx += 1,
            '0'...'9' => idx += 1,

            ':' => {
                idx += 2;
                break;
            },

            else => unreachable,
        }
    }

    var cachedNumber: u32 = 0;
    var rgb: [3]u32 = .{ 0, 0, 0 };

    while (idx < line.len) : (idx += 1) {
        switch (line[idx]) {
            // skip whitespace
            ' ' => {},

            '0'...'9' => |char| {
                cachedNumber = (cachedNumber * 10) + (char - 0x30);
            },

            'r' => {
                rgb[0] = cachedNumber;
                cachedNumber = 0;
                idx += 2;
            },

            'g' => {
                rgb[1] = cachedNumber;
                cachedNumber = 0;
                idx += 4;
            },

            'b' => {
                rgb[2] = cachedNumber;
                cachedNumber = 0;
                idx += 3;
            },

            ',' => {},

            ';' => {
                if (!isValid(rgb))
                    return false;

                rgb = .{ 0, 0, 0 };
            },

            else => unreachable,
        }
    }
    return isValid(rgb);
}
