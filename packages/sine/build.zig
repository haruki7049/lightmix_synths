const std = @import("std");
const l = @import("lightmix");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Dependencies
    const lightmix = b.dependency("lightmix", .{});

    // Modules
    const mod = b.addModule("lightmix_sine", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "lightmix", .module = lightmix.module("lightmix") },
        },
    });

    // Install
    const lib = b.addLibrary(.{
        .name = "lightmix_sine",
        .root_module = mod,
    });
    b.installArtifact(lib);

    // Example wave installation
    const wave = try l.addWave(b, mod, .{
        .func_name = "gen_example_wave",
        .wave = .{ .bits = 16, .format_code = .pcm },
    });
    l.installWave(b, wave);

    // Example wave play step
    const play = try l.addPlay(b, wave, .{});
    const play_step = b.step("play", "Play the example wave, can be compiled by \"zig build\"");
    play_step.dependOn(&play.step);

    // Unit tests
    const unit_tests = b.addTest(.{
        .root_module = mod,
    });
    const run_unit_tests = b.addRunArtifact(unit_tests);

    // Test step
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_unit_tests.step);
}
