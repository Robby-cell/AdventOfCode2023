const std = @import("std");

const input = @embedFile("./sample");
// seed-to-soil is soil then seed value

const Key = struct {
    keyType: S,
    keyStart: u64,
    range: u64,
};
var map: std.AutoHashMap(Key, u64) = undefined;
var seeds: std.ArrayList(u64) = undefined;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    map = std.AutoHashMap(Key, u64).init(allocator);
    defer map.deinit();

    seeds = std.ArrayList(u64).init(allocator);
    defer seeds.deinit();

    try parseMaps(input);
}

fn parseMaps(maps: []const u8) !void {
    const loc = std.mem.indexOf(u8, maps, ":").?;
    const line = std.mem.indexOf(u8, maps, "\n").?;
    var numberIter = std.mem.tokenizeScalar(u8, maps[loc + 1 .. line], ' ');

    while (numberIter.next()) |numberStr| {
        const number = try std.fmt.parseInt(u8, numberStr, 10);
        try seeds.append(number);
    }

    // seed to soil.
    const seedToSoil = maps[line..];
    var iterator = std.mem.tokenizeSequence(u8, seedToSoil, "\n");
    try captureGroup(&iterator, .seed);
    try captureGroup(&iterator, .soil);
    try captureGroup(&iterator, .fertilizer);
    try captureGroup(&iterator, .water);
    try captureGroup(&iterator, .light);
    try captureGroup(&iterator, .temperature);
    try captureGroup(&iterator, .humidity);
}

fn captureGroup(iterator: *std.mem.TokenIterator(u8, .sequence), keyType: S) !void {
    _ = iterator.next();
    while (iterator.next()) |lines| {
        if (!switch (lines[0]) {
            '0'...'9' => true,
            else => false,
        }) break;
        var keyValueIter = std.mem.tokenizeScalar(u8, lines, ' ');
        const value = try std.fmt.parseInt(u64, (keyValueIter.next().?), 10);
        const keyStart = try std.fmt.parseInt(u64, (keyValueIter.next().?), 10);
        const range = try std.fmt.parseInt(u64, (keyValueIter.next().?), 10);

        try map.put(.{ .keyType = keyType, .keyStart = keyStart, .range = range }, value);
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
    light,
    temperature,
    humidity,

    /// may not necessarily use this one
    location,
};
