//! Square Wave

const std = @import("std");
const lightmix = @import("lightmix");
const Wave = lightmix.Wave;

pub const GenOptions = struct {
    frequency: f32,
    amplitude: f32,
    sharpness: f32,
    length: usize,
    allocator: std.mem.Allocator,

    sample_rate: u32,
    channels: u16,
};

pub fn gen(
    comptime T: type,
    options: GenOptions,
) Wave(T) {
    const samples: []const T = generate_samples(T, options);

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
) []const T {
    const sample_rate: T = @floatFromInt(options.sample_rate);
    const radins_per_sec: T = options.frequency * (2.0 * std.math.pi);

    var result: []T = options.allocator.alloc(T, options.length) catch |err| {
        std.debug.print("{any}\n", .{err});
        @panic("PANIC");
    };

    var i: usize = 0;
    while (i < result.len) : (i += 1) {
        const sine_wave: T = std.math.sin(@as(T, @floatFromInt(i)) * radins_per_sec / sample_rate);
        result[i] = std.math.tanh(options.sharpness * sine_wave);
    }

    return result;
}

test "gen" {
    const test_data = @import("./test_data.zig");
    const allocator = std.testing.allocator;

    const square: Wave(f64) = gen(f64, .{
        .frequency = 440.0,
        .amplitude = 1.0,
        .sharpness = 0.5,
        .length = 44100,

        .allocator = allocator,

        .sample_rate = 44100,
        .channels = 1,
    });
    defer square.deinit();

    try std.testing.expectEqual(test_data.Square.len, square.samples.len);
    for (test_data.Square, square.samples) |expected, actual|
        try std.testing.expectApproxEqAbs(expected, actual, 0.00001);
}
