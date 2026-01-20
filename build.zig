const std = @import("std");
const l = @import("lightmix");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Dependencies
    const lightmix = b.dependency("lightmix", .{});

    // Modules
    const mod = b.addModule("lightmix_synths", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "lightmix", .module = lightmix.module("lightmix") },
        },
    });

    // Install
    const lib = b.addLibrary(.{
        .name = "lightmix_filters",
        .root_module = mod,
    });
    b.installArtifact(lib);

    // Unit tests
    const unit_tests = b.addTest(.{
        .root_module = mod,
    });
    const run_unit_tests = b.addRunArtifact(unit_tests);

    // Test step
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_unit_tests.step);

    // build-examples step
    const build_examples_step = b.step("build-examples", "Build all examples' Wave file");
    const paths: []const []const u8 = &.{"examples/ukulele.zig"};
    for (paths) |path| {
        const example_mod = b.createModule(.{
            .root_source_file = b.path(path),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "lightmix", .module = lightmix.module("lightmix") },
                .{ .name = "lightmix_synths", .module = mod },
            },
        });
        const filename: []const u8 = "result.wav";

        const wave_step = try l.createWave(b, example_mod, .{
            .func_name = "gen",
            .wave = .{ .bits = 16, .format_code = .pcm, .name = filename },
        });
        build_examples_step.dependOn(wave_step);
    }
}
