const std = @import("std");

const MAP_SIZE = 10;

const input = @embedFile("./sample.txt");
var MAP: [][]bool = undefined;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    MAP = try allocator.alloc([]bool, MAP_SIZE);
    for (MAP) |*row|
        row.* = try allocator.alloc(bool, MAP_SIZE);
    MAP[0][0] = true;

    var position: struct { x: u32, y: u32 } = .{ .x = 0, .y = 0 };
    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    while (lines.next()) |line| {
        const info = try infoFromLine(line);
        const dist = info.dist;
        switch (info.dir) {
            .R => {
                for (1..dist + 1) |i| {
                    MAP[position.y][position.x + i] = true;
                }
                position.x += dist;
            },
            .U => {
                for (1..dist + 1) |i| {
                    MAP[position.y - i][position.x] = true;
                }
                position.y -= dist;
            },
            .L => {
                for (1..dist + 1) |i| {
                    MAP[position.y][position.x - i] = true;
                }
                position.x -= dist;
            },
            .D => {
                for (1..dist + 1) |i| {
                    MAP[position.y + i][position.x] = true;
                }
                position.y += dist;
            },
        }
    }

    for (MAP) |row|
        std.debug.print("{any}\n", .{row});
}

fn infoFromLine(line: []const u8) !struct { dir: Dir, dist: u32 } {
    var splits = std.mem.tokenizeScalar(u8, line, ' ');
    const dir = Dir.fromStr(splits.next().?);
    const dist = try std.fmt.parseInt(u32, splits.next().?, 10);

    return .{
        .dir = dir,
        .dist = dist,
    };
}

const Dir = enum {
    U,
    D,
    L,
    R,

    fn fromStr(str: []const u8) Dir {
        return std.meta.stringToEnum(Dir, str).?;
    }
};
