const std = @import("std");
const Allocator = std.mem.Allocator;

const input = @embedFile("./input.txt");

pub fn main() !void {
    var gpa: std.heap.GeneralPurposeAllocator(.{}) = .{};
    defer if (gpa.deinit() == .leak) std.debug.print("memory leak\n", .{});
    const allocator = gpa.allocator();

    var linesIter = std.mem.tokenizeScalar(u8, input, '\n');

    var totalAhead: isize = 0;
    var totalBehind: isize = 0;

    while (linesIter.next()) |line| {
        const numbers = try nextNumber(line, allocator);
        totalAhead += numbers.next;
        totalBehind += numbers.reverse;
    }

    std.debug.print("\nanswer part 1: {d}\nanswer part 2: {d}\n", .{ totalAhead, totalBehind });
}

fn nextNumber(line: []const u8, allocator: Allocator) ParseStageError!struct { reverse: i64, next: i64 } {
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
    defer for (memory[1..]) |memBlk| allocator.free(memBlk);

    var root: isize = 0;
    var i = memory.len - 1;
    while (i > 0) : (i -= 1) {
        const endOfBlock = memory[i].len - 1;
        root += memory[i][endOfBlock];
    }
    const keyIdx = loop: for (memory, 0..) |item, keyIdx| {
        const value = item[0];
        for (item) |n| {
            if (n != value)
                continue :loop;
        }
        break :loop keyIdx;
    } else unreachable;
    var reverseIdx = keyIdx;
    var reverseRoot: isize = memory[keyIdx][0];
    while (reverseIdx > 0) : (reverseIdx -= 1) {
        const dodgyNumber = memory[reverseIdx - 1][0];
        reverseRoot = dodgyNumber - reverseRoot;
    }

    return .{ .reverse = reverseRoot, .next = numbers[numbers.len - 1] + root };
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
