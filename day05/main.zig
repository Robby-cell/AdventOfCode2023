const std = @import("std");

const input = @embedFile("./sample");
// seed-to-soil is soil then seed value

const Key = struct {
    S,
    u64,
};
var map: std.AutoHashMap(Key, u64) = undefined;
var seeds: std.ArrayList(u64) = undefined;
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
/// // the key for a soil value where seed value is 56
/// key = .{ .seed, 56 };
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
