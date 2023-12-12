const std = @import("std");
const Allocator = std.mem.Allocator;

// sample: 21

const buffer = @embedFile("./sample.txt");

pub fn main() anyerror!void {
    var gpa: std.heap.GeneralPurposeAllocator(.{}) = .{};
    defer if (gpa.deinit() == .leak) std.log.err("Memory leak\n", .{});
    const allocator = gpa.allocator();

    var linesIter = std.mem.tokenizeScalar(u8, buffer, '\n');
    var total: usize = 0;
    while (linesIter.next()) |line| {
        const field = try Field.init(line, allocator);
        defer field.deinit();

        total += field.damaged[0];
        std.debug.print("{any}\n", .{field});
    }
}

const Field = struct {
    /// This is all the springs in the line
    springs: []Spring,
    damaged: []usize,

    allocator: Allocator,

    const FieldError = error{
        OutOfMemory,
    };

    fn init(line: []const u8, allocator: Allocator) FieldError!Field {
        var split = std.mem.splitScalar(u8, line, ' ');
        const springString = split.next().?;
        const damagedString = split.next().?;

        const springs = try allocator.alloc(Spring, springString.len);
        for (springs, springString) |*spring, char| {
            spring.* = Spring.@"from u8"(char);
        }
        errdefer allocator.free(springs);

        const requiredDamaged = std.mem.count(u8, damagedString, ",") + 1;
        const damaged = try allocator.alloc(usize, requiredDamaged);
        errdefer allocator.free(damaged);

        var damagedIter = std.mem.tokenizeScalar(u8, damagedString, ',');
        var damagedIndex: usize = 0;
        while (damagedIter.next()) |d| : (damagedIndex += 1) {
            const count = std.fmt.parseInt(usize, d, 10) catch unreachable;
            damaged[damagedIndex] = count;
        }

        return .{
            .springs = springs,
            .damaged = damaged,
            .allocator = allocator,
        };
    }

    fn deinit(self: *const Field) void {
        self.allocator.free(self.damaged);
        self.allocator.free(self.springs);
    }
};

const Spring = enum {
    /// operational
    @".",
    /// damaged
    @"#",
    /// unknown
    @"?",

    /// Passing in a character that is not '.' or '#' or '?' will hit unreachable code
    fn @"from u8"(@"u8": u8) Spring {
        // should not be possible to pass in something that isn't '.' or '#' or '?'
        return std.meta.stringToEnum(Spring, &.{@"u8"}).?;
    }
};
