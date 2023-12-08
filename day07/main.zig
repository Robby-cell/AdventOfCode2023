const std = @import("std");
const ArrayList = std.ArrayList;

const input = @embedFile("./sample.txt");

const WhatCanGoWrong: type = Hand.HandCreationError || std.mem.Allocator.Error;

pub fn main() WhatCanGoWrong!void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    var hands = ArrayList(Hand).init(allocator);
    defer hands.deinit();

    while (lines.next()) |line| {
        const hand = try Hand.init(line);
        try hands.append(hand);
    }

    for (hands.items) |hand| {
        std.debug.print("{any}\n", .{hand});
    }
}

const Hand = struct {
    cards: Cards,
    stake: u10,

    const HandCreationError = error{
        @"missing labels",
        @"missing stake",
        @"invalid token",
    };

    fn init(line: []const u8) HandCreationError!Hand {
        var splitLine = std.mem.tokenizeScalar(u8, line, ' ');
        const labels = splitLine.next() orelse return HandCreationError.@"missing labels";
        const stakeStr = splitLine.next() orelse return HandCreationError.@"missing stake";

        var cards: Cards = .{};
        for (labels) |label| {
            const field = std.meta.stringToEnum(Label, &.{label}).?;
            cards.increment(field);
        }

        const stake: u10 = std.fmt.parseInt(u10, stakeStr, 10) catch return HandCreationError.@"invalid token";

        return .{
            .cards = cards,
            .stake = stake,
        };
    }
};

const Cards = packed struct {
    A: u3 = 0,
    K: u3 = 0,
    Q: u3 = 0,
    J: u3 = 0,
    T: u3 = 0,
    @"9": u3 = 0,
    @"8": u3 = 0,
    @"7": u3 = 0,
    @"6": u3 = 0,
    @"5": u3 = 0,
    @"4": u3 = 0,
    @"3": u3 = 0,
    @"2": u3 = 0,

    fn increment(self: *Cards, field: Label) void {
        switch (field) {
            .A => self.A += 1,
            .K => self.K += 1,
            .Q => self.Q += 1,
            .J => self.J += 1,
            .T => self.T += 1,
            .@"9" => self.@"9" += 1,
            .@"8" => self.@"8" += 1,
            .@"7" => self.@"7" += 1,
            .@"6" => self.@"6" += 1,
            .@"5" => self.@"5" += 1,
            .@"4" => self.@"4" += 1,
            .@"3" => self.@"3" += 1,
            .@"2" => self.@"2" += 1,
        }
    }
};

const Label = enum {
    A,
    K,
    Q,
    J,
    T,
    @"9",
    @"8",
    @"7",
    @"6",
    @"5",
    @"4",
    @"3",
    @"2",

    fn cmp(self: Label, other: Label) Ordering {
        if (self == other)
            return .equal;

        return if (@intFromEnum(self) < @intFromEnum(other)) .higher else .lower;
    }
};

const Ordering = enum(u2) {
    higher,
    equal,
    lower,
};

const @"type" = enum(u3) {
    /// All the same label
    five,

    /// Four of the same label and 1 different
    four,

    /// Three of the same label, and two other cards with matching labels
    full,

    /// Three cards with the same label, and other two with different, non matching labels
    three,

    /// Two cards share the same label, and Two other cards share the same, but different label to the first pair
    two_pair,

    /// Only one pair of cards share the same label, and the others are all different
    one_pair,

    /// No cards share the same label
    high,
};
