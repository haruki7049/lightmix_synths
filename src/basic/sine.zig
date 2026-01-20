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
    const sample_rate: f32 = @floatFromInt(options.sample_rate);
    const radins_per_sec: f32 = options.frequency * 2.0 * std.math.pi;

    var result: []T = options.allocator.alloc(T, options.length) catch |err| {
        std.debug.print("{any}\n", .{err});
        @panic("PANIC");
    };
    var i: usize = 0;

    while (i < result.len) : (i += 1) {
        result[i] = std.math.sin(@as(T, @floatFromInt(i)) * radins_per_sec / sample_rate) * options.amplitude;
    }

    return result;
}

test "gen" {
    const test_data = @import("./test_data.zig");
    const allocator = std.testing.allocator;

    const sine: Wave(f128) = gen(f128, .{
        .frequency = 440.0,
        .amplitude = 1.0,
        .length = 44100,

        .allocator = allocator,

        .sample_rate = 44100,
        .channels = 1,
    });
    defer sine.deinit();

    try std.testing.expectEqualSlices(f128, test_data.Sine, sine.samples);
}
