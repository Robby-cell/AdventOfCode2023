const std = @import("std");
const Allocator = std.mem.Allocator;

const input = @embedFile("./input.txt");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var linesIter = std.mem.tokenizeScalar(u8, input, '\n');

    var total: isize = 0;
    while (linesIter.next()) |line| {
        const number = try nextNumber(line, allocator);
        total += number;
        std.debug.print("{d}\n", .{number});
    }

    std.debug.print("\nanswer part 1: {d}\n", .{total});
}

fn nextNumber(line: []const u8, allocator: Allocator) ParseStageError!i64 {
    const numbers = try parseLine(line, allocator);
    defer allocator.free(numbers);

    const len = numbers.len;
    var memory = try allocator.alloc([]i64, len);
    defer allocator.free(memory);

    memory[0] = numbers;

    var memoryRequired = len - 1;
    for (memory[1..], 0..) |*block, idx| {
        const memoryBlock = try allocator.alloc(i64, memoryRequired);
        for (memoryBlock, 0..) |*n, i| {
            n.* = memory[idx][i + 1] - memory[idx][i];
        }
        block.* = memoryBlock;
        memoryRequired -= 1;
    }

    var root: isize = 0;
    var i = memory.len - 1;
    while (i > 0) : (i -= 1) {
        const endOfBlock = memory[i].len - 1;
        root += memory[i][endOfBlock];
    }

    return numbers[numbers.len - 1] + root;
}

const ParseStageError = std.mem.Allocator.Error || std.fmt.ParseIntError;
fn parseLine(line: []const u8, allocator: Allocator) ParseStageError![]i64 {
    const allocationRequired = std.mem.count(u8, line, " ");
    var iterator = std.mem.tokenizeScalar(u8, line, ' ');

    var numbers = try allocator.alloc(i64, allocationRequired + 1);
    var idx: usize = 0;
    while (iterator.next()) |number| : (idx += 1) {
        numbers[idx] = try std.fmt.parseInt(i64, number, 10);
    }

    return numbers;
}
