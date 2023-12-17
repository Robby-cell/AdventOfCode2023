const std = @import("std");

const Hash = usize;
const input = @embedFile("./input.txt");
// const input = "rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7";

pub fn main() void {
    var iterator = std.mem.tokenizeScalar(u8, input, ',');
    var hash: Hash = 0;
    while (iterator.next()) |segment| {
        hash += hashSegment(segment);
    }

    std.debug.print("{d}\n", .{hash});
}

fn hashSegment(segment: []const u8) Hash {
    var total: Hash = 0;
    for (segment) |char| {
        total += char;
        total *= 17;
        total %= 256;
    }
    return total;
}
