const std = @import("std");

const input = @embedFile("./input.txt");

const Game = struct {
    id: u8,
    r: usize = 0,
    g: usize = 0,
    b: usize = 0,
};

pub fn main() void {
    std.debug.print("{d}\n", .{gatherInfo(input)});
}

fn gatherInfo(file: []const u8) [2]usize {
    const eql = std.mem.eql;

    var power: usize = 0;
    var sumValid: usize = 0;
    var lines = std.mem.splitScalar(u8, file, '\n');

    while (lines.next()) |line| {
        const id = std.fmt.parseInt(u8, line[5 .. std.mem.indexOf(
            u8,
            line,
            ":",
        ) orelse break], 10) catch unreachable;

        var game: Game = .{ .id = id };

        var turns = std.mem.split(u8, line[std.mem.indexOf(
            u8,
            line,
            ":",
        ).? + 2 ..], "; ");
        while (turns.next()) |turn| {
            var colors = std.mem.splitSequence(u8, turn, ", ");

            while (colors.next()) |color| {
                const space = std.mem.indexOf(u8, color, " ").?;

                const count = std.fmt.parseInt(u8, color[0..space], 10) catch unreachable;
                if (eql(u8, color[space + 1 ..], "red"))
                    game.r = @max(game.r, count)
                else if (eql(u8, color[space + 1 ..], "green"))
                    game.g = @max(game.g, count)
                else if (eql(u8, color[space + 1 ..], "blue"))
                    game.b = @max(game.b, count);
            }
        }

        power += (game.r * game.g * game.b);
        sumValid += if (game.r <= 12 and game.g <= 13 and game.b <= 14) game.id else 0;
    }

    return .{ sumValid, power };
}
