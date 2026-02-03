//! String Synth (Karplus-Strong)

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

    feedback: f32 = 0.995, // Decay rate
};

pub fn gen(comptime T: type, options: GenOptions) !Wave(T) {
    const samples = try generate_samples(T, options);
    return Wave(T){
        .samples = samples,
        .allocator = options.allocator,
        .sample_rate = options.sample_rate,
        .channels = options.channels,
    };
}

fn generate_samples(comptime T: type, options: GenOptions) ![]const T {
    const sample_rate: T = @floatFromInt(options.sample_rate);
    const period_len: usize = @intFromFloat(sample_rate / options.frequency);
    const result = try options.allocator.alloc(T, options.length);

    // Ring buffer for the delay line
    var buffer = try options.allocator.alloc(T, period_len);
    defer options.allocator.free(buffer);

    var prng = std.Random.DefaultPrng.init(0);
    const random = prng.random();

    // 1. Initial burst (Noise)
    for (buffer) |*sample| {
        sample.* = random.float(T) * 2.0 - 1.0;
    }

    // 2. Synthesis loop
    var i: usize = 0;
    while (i < result.len) : (i += 1) {
        const buf_idx = i % period_len;
        const next_idx = (i + 1) % period_len;

        // Averaging filter (Low-pass) and feedback
        const val = (buffer[buf_idx] + buffer[next_idx]) * 0.5 * options.feedback;
        buffer[buf_idx] = val;
        result[i] = val * options.amplitude;
    }

    return result;
}

test "gen" {
    const test_data = @import("./test_data.zig");
    const allocator = std.testing.allocator;

    const karplus_strong: Wave(f64) = try gen(f64, .{
        .frequency = 440.0,
        .amplitude = 1.0,
        .length = 88200,

        .allocator = allocator,
        .sample_rate = 44100,
        .channels = 1,

        .feedback = 0.995,
    });
    defer karplus_strong.deinit();

    //for (karplus_strong.samples) |actual|
    //    std.debug.print("{d}\n", .{actual});

    try std.testing.expectEqual(test_data.KarplusStrong.len, karplus_strong.samples.len);
    for (test_data.KarplusStrong, karplus_strong.samples) |expected, actual|
        try std.testing.expectApproxEqAbs(expected, actual, 0.00001);
}
