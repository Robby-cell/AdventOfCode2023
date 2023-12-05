const std = @import("std");

const input =
    \\seeds: 79 14 55 13
    \\
    \\seed-to-soil map:
    \\50 98 2
    \\52 50 48
    \\
    \\soil-to-fertilizer map:
    \\0 15 37
    \\37 52 2
    \\39 0 15
    \\
    \\fertilizer-to-water map:
    \\49 53 8
    \\0 11 42
    \\42 0 7
    \\57 7 4
    \\
    \\water-to-light map:
    \\88 18 7
    \\18 25 70
    \\
    \\light-to-temperature map:
    \\45 77 23
    \\81 45 19
    \\68 64 13
    \\
    \\temperature-to-humidity map:
    \\0 69 1
    \\1 0 69
    \\
    \\humidity-to-location map:
    \\60 56 37
    \\56 93 4
;
// seed-to-soil is soil then seed value

const Key = struct {
    kind: S,
    value: u8,
};
var map: std.AutoHashMap(Key, u8) = undefined;
var seeds: std.ArrayList(u8) = undefined;
var lastIdx: usize = undefined;

pub fn main() void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    map.init(allocator);
    defer map.deinit();

    seeds = std.ArrayList(u8).init(allocator);
    defer seeds.deinit();
}

fn parseMaps(maps: []const u8) !void {
    const loc = std.mem.indexOf(u8, maps, ":").?;
    const line = std.mem.indexOf(u8, maps, "\n").?;
    var numberIter = std.mem.tokenizeScalar(u8, maps[loc..line], ' ');

    while (numberIter.next()) |numberStr| {
        const number = try std.fmt.parseInt(u8, numberStr, 10);
        try seeds.append(number);
    }
}

/// This denotes the input type,
/// e.g. `seed` to soil
/// ```
/// key = .{ .seed, 56 }
/// ```
const S = enum {
    seed,
    soil,
    fertilizer,
    water,
    ligh,
    temperature,
    humidity,
    location,
};
