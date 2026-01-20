const std = @import("std");
const lightmix = @import("lightmix");
const lightmix_synths = @import("lightmix_synths");

pub fn gen() !lightmix.Wave(f64) {
    const allocator = std.heap.page_allocator;
    const result: lightmix.Wave(f64) = lightmix_synths.Basic.KarplusStrong.gen(f64, .{
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
