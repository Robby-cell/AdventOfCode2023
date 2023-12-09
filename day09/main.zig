const std = @import("std");
const Allocator = std.mem.Allocator;

const input = @embedFile("./sample.txt");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const number = try nextNumber("1 3 5 7 9", allocator);

    std.debug.print("{d}\n", .{number});
}

fn nextNumber(line: []const u8, allocator: Allocator) ParseStageError!u64 {
    const numbers = try parseLine(line, allocator);
    defer allocator.free(numbers);

    const len = numbers.len;
    var memory = try allocator.alloc([]u64, len);
    defer allocator.free(memory);

    memory[0] = numbers;

    var memoryRequired = len - 1;
    for (memory[1..], 0..) |*block, idx| {
        const memoryBlock = try allocator.alloc(u64, memoryRequired);
        for (memoryBlock, 0..) |*n, i| {
            n.* = memory[idx][i + 1] - memory[idx][i];
        }
        block.* = memoryBlock;
        memoryRequired -= 1;
    }

    var root: usize = 0;
    var i = memory.len - 1;
    while (i > 0) : (i -= 1) {
        const endOfBlock = memory[i].len - 1;
        root += memory[i][endOfBlock];
    }

    return numbers[numbers.len - 1] + root;
}

const ParseStageError = std.mem.Allocator.Error || std.fmt.ParseIntError;
fn parseLine(line: []const u8, allocator: Allocator) ParseStageError![]u64 {
    const allocationRequired = std.mem.count(u8, line, " ");
    var iterator = std.mem.tokenizeScalar(u8, line, ' ');

    var numbers = try allocator.alloc(u64, allocationRequired + 1);
    var idx: usize = 0;
    while (iterator.next()) |number| : (idx += 1) {
        numbers[idx] = try std.fmt.parseInt(u64, number, 10);
    }

    return numbers;
}
