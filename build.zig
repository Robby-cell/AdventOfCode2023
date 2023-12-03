const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    comptime var dayNumber: u5 = 1;
    inline while (dayNumber <= 3) : (dayNumber += 1) {
        setupDay(b, target, optimize, dayNumber);
    }
}

fn setupDay(b: *std.Build, target: std.zig.CrossTarget, optimize: std.builtin.OptimizeMode, dayNumber: u5) void {
    const path = b.fmt("day{d:0>2}", .{dayNumber});
    const root = b.fmt("{s}/main.zig", .{path});
    const exe = b.addExecutable(.{
        .name = path,
        .root_source_file = .{ .path = root },
        .target = target,
        .optimize = optimize,
    });

    b.installArtifact(exe);
    const install_step = b.step(path, "Build the specified day");
    install_step.dependOn(b.getInstallStep());

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(install_step);

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step(b.fmt("run_{s}", .{path}), "Run the specified day");
    run_step.dependOn(&run_cmd.step);

    const test_cmd = b.addTest(.{
        .name = path,
        .root_source_file = .{ .path = root },
        .target = target,
        .optimize = optimize,
    });
    test_cmd.step.dependOn(install_step);
    const test_step = b.step(b.fmt("test_{s}", .{path}), "Test the specified day");
    test_step.dependOn(&test_cmd.step);
}
