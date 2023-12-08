const std = @import("std");

// We are given a string of moves we can make, RLR etc.
// (R for right, L for left)
// This means we have to go R then L then R
// then we ran out of moves, so we have to go back to the beginning of "available" moves
// i.e. after RLR, we can go RLR again.
// Have to keep going until we hit ZZZ

const input = @embedFile("./input.txt");

/// Target: ZZZ
const target: Point = .{ .@"1" = .Z, .@"2" = .Z, .@"3" = .Z };

const GlobalError = Lexer.YieldError || std.mem.Allocator.Error;

pub fn main() GlobalError!void {
    var gpa: std.heap.GeneralPurposeAllocator(.{}) = .{};
    defer if (gpa.deinit() == .leak) std.debug.print("memory leak\n", .{});
    const allocator = gpa.allocator();

    const newlineChar = std.mem.indexOf(u8, input, "\n").?;
    var turns = try Turns.init(allocator, input[0..newlineChar]);
    defer turns.deinit();

    var map = std.AutoHashMap(Point, Options).init(allocator);
    defer map.deinit();

    var lexer = Lexer.init(input[newlineChar..]);
    while (true) {
        const mapping = lexer.yield() catch break;
        try map.put(mapping.at, mapping.options);
    }
    var step: usize = 0;
    var current: Point = .{ .@"1" = .A, .@"2" = .A, .@"3" = .A };

    while (!std.meta.eql(current, target)) {
        const dir = turns.next();

        current = map.get(current).?.@"with direction"(dir);
        step += 1;
    }

    std.debug.print("{d} attempts, oof!\n", .{step});
}

const Direction = enum { L, R };
const Turns = struct {
    sequence: []Direction,
    index: usize = 0,
    allocator: std.mem.Allocator,

    fn init(allocator: std.mem.Allocator, buffer: []const u8) std.mem.Allocator.Error!Turns {
        const seq = try allocator.alloc(Direction, buffer.len);
        for (seq, buffer) |*dir, letter| {
            dir.* = std.meta.stringToEnum(Direction, &.{letter}).?;
        }

        return .{
            .sequence = seq,
            .allocator = allocator,
        };
    }

    fn deinit(self: *Turns) void {
        self.allocator.free(self.sequence);
    }

    fn next(self: *Turns) Direction {
        const current = self.index;
        self.index += 1;

        if (self.index >= self.sequence.len)
            self.index = 0;

        return self.sequence[current];
    }
};

const Lexer = struct {
    const Error = error{
        OutOfBuffer,
    };

    buffer: []const u8,
    index: usize,

    fn init(buffer: []const u8) Lexer {
        return .{
            .buffer = buffer,
            .index = 0,
        };
    }

    fn bump(self: *Lexer) ?u8 {
        if (self.index >= self.buffer.len - 1)
            return null;

        self.index += 1;
        return self.buffer[self.index];
    }

    fn bumpLetter(self: *Lexer) ?u8 {
        const next = self.bump() orelse 255;
        switch (next) {
            'A'...'Z' => return next,
            else => return null,
        }
    }

    fn current(self: *const Lexer) ?u8 {
        if (self.index >= self.buffer.len)
            return null;

        return self.buffer[self.index];
    }

    const YieldError = Point.Error || Error;
    fn yield(self: *Lexer) YieldError!Mapping {
        var at: []const u8 = undefined;
        var left: []const u8 = undefined;
        var right: []const u8 = undefined;

        var mode = enum { at, left, right }.at;

        while (true) {
            switch (self.current() orelse 255) {
                255 => return Error.OutOfBuffer,

                'A'...'Z' => {
                    const start = self.index;
                    while (self.bumpLetter()) |_| {}
                    const end = self.index;
                    switch (mode) {
                        .at => {
                            at = self.buffer[start..end];
                            mode = .left;
                        },
                        .left => {
                            left = self.buffer[start..end];
                            mode = .right;
                        },
                        .right => {
                            right = self.buffer[start..end];
                            return try Mapping.init(at, left, right);
                        },
                    }
                },

                else => _ = self.bump() orelse return Error.OutOfBuffer,
            }
        }
    }
};

const Options = struct {
    left: Point,
    right: Point,

    fn @"with direction"(self: Options, dir: Direction) Point {
        return switch (dir) {
            .L => self.left,
            .R => self.right,
        };
    }
};

const Mapping = struct {
    at: Point,
    options: Options,

    fn init(at: []const u8, l: []const u8, r: []const u8) Point.Error!Mapping {
        return .{
            .at = try Point.fromString(at),
            .options = .{
                .left = try Point.fromString(l),
                .right = try Point.fromString(r),
            },
        };
    }
};

const Point = packed struct {
    @"1": SubPoint,
    @"2": SubPoint,
    @"3": SubPoint,

    const Error = error{
        InvalidCharacterCount,
    };
    fn fromString(string: []const u8) Error!Point {
        if (string.len != 3)
            return Error.InvalidCharacterCount;

        return .{
            .@"1" = SubPoint.from_u8(string[0]),
            .@"2" = SubPoint.from_u8(string[1]),
            .@"3" = SubPoint.from_u8(string[2]),
        };
    }
};

const SubPoint = enum {
    A,
    B,
    C,
    D,
    E,
    F,
    G,
    H,
    I,
    J,
    K,
    L,
    M,
    N,
    O,
    P,
    Q,
    R,
    S,
    T,
    U,
    V,
    W,
    X,
    Y,
    Z,

    fn from_u8(@"u8": u8) SubPoint {
        return std.meta.stringToEnum(SubPoint, &.{@"u8"}).?;
    }
};
