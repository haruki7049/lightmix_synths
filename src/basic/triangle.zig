//! Triangle Wave

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
    const period: T = sample_rate / options.frequency;

    var result: []T = options.allocator.alloc(T, options.length) catch |err| {
        std.debug.print("{any}\n", .{err});
        @panic("PANIC");
    };

    var i: usize = 0;
    while (i < result.len) : (i += 1) {
        const t: T = @floatFromInt(i);
        const phase: T = @mod(t, period) / period;

        // Triangle wave: rises from -1 to 1 at phase 0.5, then falls back to -1
        const triangle_value: T = if (phase < 0.5)
            4.0 * phase - 1.0
        else
            3.0 - 4.0 * phase;

        result[i] = triangle_value * options.amplitude;
    }

    return result;
}

test "gen" {
    const test_data = @import("./test_data.zig");
    const allocator = std.testing.allocator;

    const triangle: Wave(f128) = gen(f128, .{
        .frequency = 440.0,
        .amplitude = 1.0,
        .length = 44100,

        .allocator = allocator,

        .sample_rate = 44100,
        .channels = 1,
    });
    defer triangle.deinit();

    //for (triangle.samples) |actual|
    //    std.debug.print("{d}\n", .{actual});

    try std.testing.expectEqual(test_data.Triangle.len, triangle.samples.len);
    for (test_data.Triangle, triangle.samples) |expected, actual|
        try std.testing.expectApproxEqAbs(expected, actual, 0.00001);
}
