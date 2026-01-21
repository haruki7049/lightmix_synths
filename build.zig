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

    // examples step
    const examples_step = b.step("examples", "Build all examples' Wave file");

    var dir = try std.fs.cwd().openDir("examples", .{ .iterate = true });
    defer dir.close();
    var walker = try dir.walk(b.allocator);
    defer walker.deinit();

    while (try walker.next()) |entry| {
        const p: []const u8 = try std.fs.path.join(b.allocator, &.{ "examples", entry.path });
        const filename: []const u8 = try std.mem.concat(b.allocator, u8, &.{ entry.path, ".wav" });

        const example_mod = b.createModule(.{
            .root_source_file = b.path(p),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "lightmix", .module = lightmix.module("lightmix") },
                .{ .name = "lightmix_synths", .module = mod },
            },
        });

        const wave_step = try l.createWave(b, example_mod, .{
            .func_name = "gen",
            .wave = .{ .bits = 16, .format_code = .pcm, .name = filename },
        });
        examples_step.dependOn(wave_step);
    }
}
