const std = @import("std");
const lightmix = @import("lightmix");
const lightmix_synths = @import("lightmix_synths");

pub fn gen(allocator: std.mem.Allocator) !lightmix.Wave(f64) {
    const result: lightmix.Wave(f64) = try lightmix_synths.Basic.KarplusStrong.gen(f64, .{
        .frequency = 440.0,
        .amplitude = 1.0,
        .length = 88200,

        .allocator = allocator,
        .sample_rate = 44100,
        .channels = 1,

        .feedback = 0.995,
    });

    return result;
}
