const std = @import("std");

const NumMap = std.AutoHashMap(u8, void);
const NumList = std.ArrayList(u8);

// const input =
//     \\Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
//     \\Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
//     \\Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
//     \\Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
//     \\Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
//     \\Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
// ;
const input = @embedFile("./input.txt");

pub fn main() !void {
    var rawGpa: std.heap.GeneralPurposeAllocator(.{}) = .{};
    defer _ = rawGpa.deinit();
    const allocator = rawGpa.allocator();
    var gameLines = std.mem.splitScalar(u8, input, '\n');
    var total: usize = 0;

    while (gameLines.next()) |line| {
        var game = try Game.fromLine(line, allocator);
        defer game.deinit();
        game.getPoints();
        total += game.points;
    }

    std.debug.print("{d}\n", .{total});
}

const Game = struct {
    winning: NumMap,
    picked: NumList,

    matches: u32 = 0,

    points: u32 = 0,

    fn getPoints(self: *Game) void {
        for (self.picked.items) |number| {
            if (self.winning.contains(number))
                self.matches += 1;
        }

        const points = @as(u32, 1) << @as(u5, @truncate(self.matches));

        self.points = points >> 1;
    }

    fn fromLine(line: []const u8, allocator: std.mem.Allocator) !Game {
        var winningMap = blk: {
            const beginWinning = std.mem.indexOf(u8, line, ":").? + 1;
            const endWinning = std.mem.indexOf(u8, line, "|").? - 1;
            const winningLine = line[beginWinning..endWinning];
            var winningIter = std.mem.tokenizeScalar(u8, winningLine, ' ');

            var winningMap = NumMap.init(allocator);
            errdefer winningMap.deinit();

            while (winningIter.next()) |number| {
                try winningMap.put(try std.fmt.parseInt(u8, number, 10), undefined);
            }
            break :blk winningMap;
        };
        errdefer winningMap.deinit();

        const picked = blk: {
            const beginPicked = std.mem.indexOf(u8, line, "|").? + 2;
            var pickedIter = std.mem.tokenizeScalar(u8, line[beginPicked..], ' ');

            var picked = NumList.init(allocator);
            errdefer picked.deinit();

            while (pickedIter.next()) |number| {
                try picked.append(try std.fmt.parseInt(u8, number, 10));
            }

            break :blk picked;
        };

        return .{
            .winning = winningMap,
            .picked = picked,
        };
    }

    fn deinit(self: *Game) void {
        self.picked.deinit();
        self.winning.deinit();
    }
};
