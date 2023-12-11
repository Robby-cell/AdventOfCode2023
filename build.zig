const std = @import("std");

const day = 11;

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    @"add zig"(1, day, b, target, optimize);
    @"add cpp"(1, day, b, target, optimize);
    @"add c"(1, day, b, target, optimize);
}

fn @"add zig"(
    comptime from: u5,
    comptime to: u5,
    b: *std.Build,
    target: std.zig.CrossTarget,
    optimize: std.builtin.OptimizeMode,
) void {
    comptime var dayNumber = from;
    inline while (dayNumber <= to) : (dayNumber += 1) {
        setupDay(b, target, optimize, dayNumber);
    }
}

fn @"add cpp"(
    comptime from: u5,
    comptime to: u5,
    b: *std.Build,
    target: std.zig.CrossTarget,
    optimize: std.builtin.OptimizeMode,
) void {
    inline for (from..to + 1) |dayNumber| {
        const path = b.fmt("day{d:0>2}", .{dayNumber});
        const root = b.fmt("{s}/main.cpp", .{path});
        const exe = b.addExecutable(.{
            .name = b.fmt("{s}cpp", .{path}),
            .root_source_file = .{ .path = root },
            .target = target,
            .optimize = optimize,
        });
        exe.linkLibCpp();

        b.installArtifact(exe);

        const install_step = b.step(b.fmt("{s}cpp", .{path}), "Build the specified day");
        install_step.dependOn(b.getInstallStep());

        const run_cmd = b.addRunArtifact(exe);
        run_cmd.step.dependOn(install_step);

        if (b.args) |args| {
            run_cmd.addArgs(args);
        }

        const run_step = b.step(b.fmt("cpp_{s}", .{path}), "Run the specified day");
        run_step.dependOn(&run_cmd.step);
    }
}

fn @"add c"(
    comptime from: u5,
    comptime to: u5,
    b: *std.Build,
    target: std.zig.CrossTarget,
    optimize: std.builtin.OptimizeMode,
) void {
    inline for (from..to + 1) |dayNumber| {
        const path = b.fmt("day{d:0>2}", .{dayNumber});
        const root = b.fmt("{s}/main.c", .{path});
        const exe = b.addExecutable(.{
            .name = b.fmt("{s}c", .{path}),
            .root_source_file = .{ .path = root },
            .target = target,
            .optimize = optimize,
        });
        exe.linkLibC();

        b.installArtifact(exe);

        const install_step = b.step(b.fmt("{s}c", .{path}), "Build the specified day");
        install_step.dependOn(b.getInstallStep());

        const run_cmd = b.addRunArtifact(exe);
        run_cmd.step.dependOn(install_step);

        if (b.args) |args| {
            run_cmd.addArgs(args);
        }

        const run_step = b.step(b.fmt("c_{s}", .{path}), "Run the specified day");
        run_step.dependOn(&run_cmd.step);
    }
}

fn setupDay(b: *std.Build, target: std.zig.CrossTarget, optimize: std.builtin.OptimizeMode, dayNumber: u5) void {
    const path = b.fmt("day{d:0>2}", .{dayNumber});
    const root = b.fmt("{s}/main.zig", .{path});
    const exe = b.addExecutable(.{
        .name = b.fmt("{s}zig", .{path}),
        .root_source_file = .{ .path = root },
        .target = target,
        .optimize = optimize,
    });

    b.installArtifact(exe);
    const install_step = b.step(b.fmt("{s}zig", .{path}), "Build the specified day");
    install_step.dependOn(b.getInstallStep());

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(install_step);

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step(b.fmt("zig_{s}", .{path}), "Run the specified day");
    run_step.dependOn(&run_cmd.step);

    // const test_cmd = b.addTest(.{
    //     .name = path,
    //     .root_source_file = .{ .path = root },
    //     .target = target,
    //     .optimize = optimize,
    // });
    // test_cmd.step.dependOn(install_step);
    // const test_step = b.step(b.fmt("test_{s}", .{path}), "Test the specified day");
    // test_step.dependOn(&test_cmd.step);
}
