//! Sine Wave

const std = @import("std");
const lightmix = @import("lightmix");
const Wave = lightmix.Wave;

pub const GenOptions = struct {
    frequency: f32,
    amplitude: f32,
    length: usize,
    allocator: std.mem.Allocator,

    sample_rate: u32,
    channels: u16,
};

pub fn gen_example_wave(allocator: std.mem.Allocator) !Wave(f128) {
    const sample_rate = 44100;
    const channels = 1;

    const result: Wave(f128) = try gen(f128, .{
        .frequency = 220.0, // A3
        .amplitude = 1.0,
        .length = 88200,
        .allocator = allocator,
        .sample_rate = sample_rate,
        .channels = channels,
    });

    return result;
}

pub fn gen(
    comptime T: type,
    options: GenOptions,
) !Wave(T) {
    const samples: []const T = try generate_samples(T, options);

    const result: Wave(T) = Wave(T){
        .samples = samples,
        .allocator = options.allocator,
        .sample_rate = options.sample_rate,
        .channels = options.channels,
    };

    return result;
}

fn generate_samples(
    comptime T: type,
    options: GenOptions,
) ![]const T {
    const sample_rate: f32 = @floatFromInt(options.sample_rate);
    const radins_per_sec: f32 = options.frequency * 2.0 * std.math.pi;

    var result: []T = try options.allocator.alloc(T, options.length);
    var i: usize = 0;

    while (i < result.len) : (i += 1) {
        result[i] = std.math.sin(@as(T, @floatFromInt(i)) * radins_per_sec / sample_rate) * options.amplitude;
    }

    return result;
}

test "gen" {
    const test_data = @import("./test_data.zig");
    const allocator = std.testing.allocator;

    const sine: Wave(f128) = try gen(f128, .{
        .frequency = 440.0,
        .amplitude = 1.0,
        .length = 44100,

        .allocator = allocator,

        .sample_rate = 44100,
        .channels = 1,
    });
    defer sine.deinit();

    try std.testing.expectEqual(test_data.Sine.len, sine.samples.len);

    for (test_data.Sine, sine.samples) |expected, actual|
        try std.testing.expectApproxEqAbs(expected, actual, 0.00001);
}
