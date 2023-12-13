const std = @import("std");

const zig: []const [2]u5 = &.{.{ 1, 12 }};
const c: []const [2]u5 = &.{.{ 1, 12 }};
const cpp: []const [2]u5 = &.{.{ 1, 12 }};

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    inline for (zig) |tuple| {
        @"add zig"(tuple[0], tuple[1], b, target, optimize);
    }
    inline for (zig) |tuple| {
        @"add c"(tuple[0], tuple[1], b, target, optimize);
    }
    inline for (zig) |tuple| {
        @"add cpp"(tuple[0], tuple[1], b, target, optimize);
    }
}

fn @"add zig"(
    comptime from: u5,
    comptime to: u5,
    b: *std.Build,
    target: std.zig.CrossTarget,
    optimize: std.builtin.OptimizeMode,
) void {
    inline for (from..to + 1) |dayNumber| {
        setupDay(
            b,
            target,
            optimize,
            dayNumber,
            "zig",
            null,
        );
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
        setupDay(
            b,
            target,
            optimize,
            dayNumber,
            "cpp",
            struct {
                fn callback(exe: *std.Build.Step.Compile) void {
                    exe.linkLibCpp();
                }
            }.callback,
        );
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
        setupDay(
            b,
            target,
            optimize,
            dayNumber,
            "c",
            struct {
                fn callback(exe: *std.Build.Step.Compile) void {
                    exe.linkLibC();
                }
            }.callback,
        );
    }
}

fn setupDay(
    b: *std.Build,
    target: std.zig.CrossTarget,
    optimize: std.builtin.OptimizeMode,
    dayNumber: u5,
    @"type": []const u8,
    maybeCallback: ?*const fn (*std.Build.Step.Compile) void,
) void {
    const path = b.fmt("day{d:0>2}", .{dayNumber});
    const root = b.fmt("{s}/main.{s}", .{ path, @"type" });
    const exe = b.addExecutable(.{
        .name = b.fmt("{s}{s}", .{ path, @"type" }),
        .root_source_file = .{ .path = root },
        .target = target,
        .optimize = optimize,
    });
    if (maybeCallback) |callback|
        callback(exe);

    b.installArtifact(exe);
    const install_step = b.step(b.fmt("{s}{s}", .{ path, @"type" }), "Build the specified day");
    install_step.dependOn(b.getInstallStep());

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(install_step);

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step(b.fmt("{s}_{s}", .{ @"type", path }), "Run the specified day");
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
